//Quelle: https://developer.chrome.com/docs/capabilities/web-apis/gpu-compute
let console={log:function(arg) {Log1.innerHTML=Log1.innerHTML+'\n'+arg}};
console.log('script');

window.onerror=function(message, file, line, col, error) {console.log('<span style="color:red">ERROR</span> message '+message+'\nfile: '+file+'\nline: '+line+'\ncol: '+col+'\nerror: '+error+'\n\n')};

  if (!("gpu" in navigator)) {
    alert( "WebGPU is not supported. Enable chrome://flags/#enable-unsafe-webgpu flag." );
  } else console.log('drin');

  const adapter = await navigator.gpu.requestAdapter();

  if (!adapter) {
    console.log("Failed to get GPU adapter.");
  }

  const device = await adapter.requestDevice();

console.log('device ist da');

/*
  // Get a GPU buffer in a mapped state and an arrayBuffer for writing.
  const gpuWriteBuffer = device.createBuffer({
    mappedAtCreation: true,
    size: 4,
    usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC
  });

console.log('gpuWriteBuffer ist erzeugt: '+gpuWriteBuffer);

  const arrayBuffer=gpuWriteBuffer.getMappedRange();

console.log('arrayBuffer ist erzeugt: '+arrayBuffer);

  new Uint8Array(arrayBuffer).set([0, 1, 2, 4]);
  
console.log('arrayBuffer ist gefüllt.');

  gpuWriteBuffer.unmap();

console.log('gpuWriteBuffer.unmap()');

  const gpuReadBuffer=device.createBuffer({
    mappedAtCreation: false,
    size: 4,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
  });

console.log('gpuReadBuffer ist erzeugt: '+gpuReadBuffer);

  const copyEncoder = device . createCommandEncoder();
  copyEncoder . copyBufferToBuffer(
    gpuWriteBuffer,
    0,
    gpuReadBuffer,
    0,
    4
    );
    
console.log('copyEncoder ist erzeugt und gefüllt: '+copyEncoder);

  const copyCommands = copyEncoder . finish();
  device . queue . submit ( [ copyCommands ] ) ;
console.log('copyCommands ist erzeugt und ausgeführt: '+copyCommands);

  await gpuReadBuffer . mapAsync ( GPUMapMode . READ ) ;

console.log('await gpuReadBuffer . mapAsync ');

  const copyArrayBuffer = gpuReadBuffer . getMappedRange ( ) ;

console.log('copyArrayBuffer ist erzeugt: '+copyArrayBuffer);

console.log('Ergebnis: '+(new Uint8Array ( copyArrayBuffer) +'--------------------------------------') ) ;

*/

console.log('jetzt das Beispiel 2, erweitert von m=a*b auf m=m+a*b');


// First Matrix

const firstMatrix = new Float32Array([
  4 , 2, //Anzahl Zeilen, Anzahl Spalten
  1, 2,
  3, 4,
  5, 6,
  7, 8
]);

let gpuWriteFirstMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: firstMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC
});

console.log('gpuWriteFirstMatrix ist erzeugt: '+gpuWriteFirstMatrix);


let arrayBufferFirstMatrix = gpuWriteFirstMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(firstMatrix);
gpuWriteFirstMatrix.unmap();

console.log('arrayBufferFirstMatfix ist erzeugt und gefüllt und .ummap(): '+arrayBufferFirstMatrix);


let gpuBufferFirstMatrix = device.createBuffer({
  size: firstMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
});

console.log('gpuBufferFirstMatrix ist erzeugt: '+gpuBufferFirstMatrix);


// Second Matrix

const secondMatrix = new Float32Array([
  2, 4, //Anzahl Zeilen, Anzahl Spalten
  1, 2, 3, 4,
  5, 6, 7, 8
]);

const gpuWriteSecondMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: secondMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC,
});
const arrayBufferSecondMatrix = gpuWriteSecondMatrix.getMappedRange();
new Float32Array(arrayBufferSecondMatrix).set(secondMatrix);
gpuWriteSecondMatrix.unmap();

const gpuBufferSecondMatrix = device.createBuffer({
  size: secondMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
});

console.log('arrayBufferSecondMatrix ist erzeugt und gefüllt und .ummap(): '+arrayBufferFirstMatrix);

// Result Matrix

const resultMatrix = new Float32Array([
  4, 4, //Anzahl Zeilen, Anzahl Spalten
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000
]);


const resultMatrixBufferSize = Float32Array.BYTES_PER_ELEMENT * (2 + firstMatrix[0] * secondMatrix[1]);
const resultMatrixBuffer = device.createBuffer({
  mappedAtCreation: true,
  size: resultMatrixBufferSize,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
});
const arrayBufferResultMatrix = resultMatrixBuffer.getMappedRange();
new Float32Array(arrayBufferResultMatrix).set(resultMatrix);
resultMatrixBuffer.unmap();

console.log('resultMatrixBuffer ist erzeugt:'+resultMatrixBuffer);


const bindGroupLayout = device.createBindGroupLayout({
  entries: [
    {
      binding: 0,
      visibility: GPUShaderStage.COMPUTE,
      buffer: {
        type: "read-only-storage"
      }
    },
    {
      binding: 1,
      visibility: GPUShaderStage.COMPUTE,
      buffer: {
        type: "read-only-storage"
      }
    },
    {
      binding: 2,
      visibility: GPUShaderStage.COMPUTE,
      buffer: {
        type: "storage"
      }
    }
  ]
});

let bindGroup = device.createBindGroup({
  layout: bindGroupLayout,
  entries: [
    {
      binding: 0,
      resource: {
        buffer: gpuBufferFirstMatrix
      }
    },
    {
      binding: 1,
      resource: {
        buffer: gpuBufferSecondMatrix
      }
    },
    {
      binding: 2,
      resource: {
        buffer: resultMatrixBuffer
      }
    }
  ]
});

console.log('bindGroup ist erzeugt wofür auch immer:'+bindGroup);




const shaderModule = device.createShaderModule({
  code: `
    struct Matrix {
      size : vec2f,
      numbers: array<f32>,
    }

    @group(0) @binding(0) var<storage, read> firstMatrix : Matrix;
    @group(0) @binding(1) var<storage, read> secondMatrix : Matrix;
    @group(0) @binding(2) var<storage, read_write> resultMatrix : Matrix;

    @compute @workgroup_size(8, 8)
    fn main(@builtin(global_invocation_id) global_id : vec3u) {
      // Guard against out-of-bounds work group sizes
      if (global_id.x >= u32(firstMatrix.size.x) || global_id.y >= u32(secondMatrix.size.y)) {
        return;
      }

      resultMatrix.size = vec2(firstMatrix.size.x, secondMatrix.size.y);

      let resultCell = vec2(global_id.x, global_id.y);
      let index = resultCell.y + resultCell.x * u32(secondMatrix.size.y);
      var result = resultMatrix.numbers[index];
      for (var i = 0u; i < u32(firstMatrix.size.y); i = i + 1u) {
        let a = i + resultCell.x * u32(firstMatrix.size.y);
        let b = resultCell.y + i * u32(secondMatrix.size.y);
        result = result + firstMatrix.numbers[a] * secondMatrix.numbers[b];
      }
      resultMatrix.numbers[index] = result;
    }
  `
});

console.log('shaderModule ist erzeugt wofür auch immer:'+shaderModule);


let computePipeline = device.createComputePipeline({
  layout: device.createPipelineLayout({
    bindGroupLayouts: [bindGroupLayout]
  }),
  compute: {
    module: shaderModule,
    entryPoint: "main"
  }
});

console.log('computePipeline ist erzeugt wofür auch immer:'+computePipeline);



let commandEncoder = device.createCommandEncoder();

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  gpuWriteFirstMatrix,
  0,
  gpuBufferFirstMatrix,
  0,
  firstMatrix.byteLength
);

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  gpuWriteSecondMatrix,
  0,
  gpuBufferSecondMatrix,
  0,
  secondMatrix.byteLength
);

let passEncoder = commandEncoder.beginComputePass();
passEncoder.setPipeline(computePipeline);
passEncoder.setBindGroup(0, bindGroup);
const workgroupCountX = Math.ceil(firstMatrix[0] / 8);
const workgroupCountY = Math.ceil(secondMatrix[1] / 8);
passEncoder.dispatchWorkgroups(workgroupCountX, workgroupCountY);
passEncoder.end();

console.log('passEncoder.end wie auch immer:'+passEncoder);
console.log('mit Math.ceil(firstMatrix[0] / 8)='+Math.ceil(firstMatrix[0] / 8));


// Get a GPU buffer for reading in an unmapped state.
const gpuReadBuffer = device.createBuffer({
  size: resultMatrixBufferSize,
  usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
});

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  resultMatrixBuffer,
  0,
  gpuReadBuffer,
  0,
  resultMatrixBufferSize
);

// Submit GPU commands.
let gpuCommands = commandEncoder.finish();
device.queue.submit([gpuCommands]);

console.log('device.queue.submit([gpuCommands]); ist auch durch');

// Read buffer.
await gpuReadBuffer.mapAsync(GPUMapMode.READ);
let arrayBuffer = gpuReadBuffer.getMappedRange();
console.log(new Float32Array(arrayBuffer));
gpuReadBuffer.unmap();
console.log('gpuReadBuffer.unmap()');


//♦erste Matrix direkt modifizieren
firstMatrix[2]=-10;
console.log('firstMatrix[2]='+firstMatrix[2]);

await gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);
console.log('Versuch await gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);');
arrayBufferFirstMatrix = gpuWriteFirstMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(firstMatrix);
gpuWriteFirstMatrix.unmap();
console.log('dann .set(firstMatrix) und .unmap()');

//zweite Matrix direkt modifizieren
secondMatrix[9]=88888;
console.log('secondMatrix[9]='+secondMatrix[0]);

await gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);
console.log('Versuch await gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);');
arrayBufferFirstMatrix = gpuWriteSecondMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(secondMatrix);
gpuWriteSecondMatrix.unmap();
console.log('dann .set(secondMatrix) und .unmap()');




console.log('♦ erneuter Durchlauf ab commandEncoder = device.createCommandEncoder()');

commandEncoder = device.createCommandEncoder();

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  gpuWriteFirstMatrix,
  0,
  gpuBufferFirstMatrix,
  0,
  firstMatrix.byteLength
);

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  gpuWriteSecondMatrix,
  0,
  gpuBufferSecondMatrix,
  0,
  secondMatrix.byteLength
);

passEncoder = commandEncoder.beginComputePass();
passEncoder.setPipeline(computePipeline);
passEncoder.setBindGroup(0, bindGroup);
passEncoder.dispatchWorkgroups(workgroupCountX, workgroupCountY);
passEncoder.end();

console.log('passEncoder.end wie auch immer:'+passEncoder);


// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  resultMatrixBuffer,
  0,
  gpuReadBuffer,
  0,
  resultMatrixBufferSize
);

// Submit GPU commands.
gpuCommands = commandEncoder.finish();
device.queue.submit([gpuCommands]);

console.log('device.queue.submit([gpuCommands2]); ist auch durch');

// Read buffer.
await gpuReadBuffer.mapAsync(GPUMapMode.READ);
arrayBuffer = gpuReadBuffer.getMappedRange();
console.log(new Float32Array(arrayBuffer));


console.log('/script');
