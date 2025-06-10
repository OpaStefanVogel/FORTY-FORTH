//Quelle: https://developer.chrome.com/docs/capabilities/web-apis/gpu-compute
let console={log:function(arg) {Log1.innerHTML=Log1.innerHTML+'\n'+arg}};
console.log('script');

window.onerror=function(message, file, line, col, error) {console.log('<span style="color:red">ERROR</span> message '+message+'\nfile: '+file+'\nline: '+line+'\ncol: '+col+'\nerror: '+error+'\n\n')};
window.addEventListener('error',function(arg) {console.log('<span style="color:red">ERROR ERROR</span> message '+arg.error.message+' '+arg.error.name); for (let i of arg.error) console.log(i)});
//throw Error('Testerror');

// First Matrix

const firstMatrix = new Float32Array([
  4 , 2, //Anzahl Zeilen, Anzahl Spalten
  1, 2,
  3, 4,
  5, 6,
  7, 8
]);

// Second Matrix

const secondMatrix = new Float32Array([
  2, 4, //Anzahl Zeilen, Anzahl Spalten
  1, 2, 3, 4,
  5, 6, 7, 8
]);

// Result Matrix

const resultMatrix = new Float32Array([
  4, 4, //Anzahl Zeilen, Anzahl Spalten
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000,
  100000, 100000, 100000, 100000
]);







let DEV={firstMatrix:firstMatrix, secondMatrix:secondMatrix,resultMatrix:resultMatrix};

async function gpu_init(RET) { 
  if (!("gpu" in navigator)) {
    alert( "WebGPU is not supported. Enable chrome://flags/#enable-unsafe-webgpu flag." );
  } else console.log('drin');

  const adapter = await navigator.gpu.requestAdapter();

  if (!adapter) {
    console.log("Failed to get GPU adapter.");
  }

  const device = await adapter.requestDevice();
  

console.log('device ist da');

console.log('jetzt das Beispiel 2, erweitert von m=a*b auf m=m+a*b');


let gpuWriteFirstMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: RET.firstMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC
});

console.log('gpuWriteFirstMatrix ist erzeugt: '+gpuWriteFirstMatrix);


let arrayBufferFirstMatrix = gpuWriteFirstMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(RET.firstMatrix);
gpuWriteFirstMatrix.unmap();

console.log('arrayBufferFirstMatfix ist erzeugt und gefüllt und .unmap(): '+arrayBufferFirstMatrix);


let gpuBufferFirstMatrix = device.createBuffer({
  size: RET.firstMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
});

console.log('gpuBufferFirstMatrix ist erzeugt: '+gpuBufferFirstMatrix);


const gpuWriteSecondMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: RET.secondMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC,
});
const arrayBufferSecondMatrix = gpuWriteSecondMatrix.getMappedRange();
new Float32Array(arrayBufferSecondMatrix).set(RET.secondMatrix);
gpuWriteSecondMatrix.unmap();

const gpuBufferSecondMatrix = device.createBuffer({
  size: RET.secondMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
});

console.log('arrayBufferSecondMatrix ist erzeugt und gefüllt und .unmap(): '+arrayBufferFirstMatrix);



//const resultMatrixBufferSize = Float32Array.BYTES_PER_ELEMENT * (2 + RET.firstMatrix[0] * RET.secondMatrix[1]);
const resultMatrixBuffer = device.createBuffer({
  mappedAtCreation: true,
  size: RET.resultMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
});
const arrayBufferResultMatrix = resultMatrixBuffer.getMappedRange();
new Float32Array(arrayBufferResultMatrix).set(RET.resultMatrix);
resultMatrixBuffer.unmap();

console.log('resultMatrixBuffer ist erzeugt:'+resultMatrixBuffer);

// Get a GPU buffer for reading in an unmapped state.
const gpuReadBuffer = device.createBuffer({
  size: RET.resultMatrix.byteLength,
  usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
});


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

RET.device=device;
RET.bindGroupLayout=bindGroupLayout;
RET.bindGroup=bindGroup;
RET.shaderModule=shaderModule;
RET.gpuWriteFirstMatrix=gpuWriteFirstMatrix;
RET.gpuBufferFirstMatrix=gpuBufferFirstMatrix;
RET.gpuWriteSecondMatrix=gpuWriteSecondMatrix;
RET.gpuBufferSecondMatrix=gpuBufferSecondMatrix;
RET.resultMatrixBuffer=resultMatrixBuffer;
RET.gpuReadBuffer=gpuReadBuffer;

return [device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer];
}

let [device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer]=await gpu_init(DEV);
console.log(device);



async function gpu_run(DEV,device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer) {
console.log('DEV.firstMatrix=['+DEV.firstMatrix);
console.log('DEV.secondMatrix=['+DEV.secondMatrix);

await gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);
console.log('Versuch await gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);');
let arrayBufferFirstMatrix = gpuWriteFirstMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(DEV.firstMatrix);
gpuWriteFirstMatrix.unmap();
console.log('dann .set(firstMatrix) und .unmap()');

await gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);
console.log('Versuch await gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);');
arrayBufferFirstMatrix = gpuWriteSecondMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(DEV.secondMatrix);
gpuWriteSecondMatrix.unmap();
console.log('dann .set(secondMatrix) und .unmap()');




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


// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  resultMatrixBuffer,
  0,
  gpuReadBuffer,
  0,
  resultMatrix.byteLength
);

// Submit GPU commands.
let gpuCommands = commandEncoder.finish();
device.queue.submit([gpuCommands]);

await gpuReadBuffer.mapAsync(GPUMapMode.READ);
let arrayBuffer = gpuReadBuffer.getMappedRange();
console.log(new Float32Array(arrayBuffer));
gpuReadBuffer.unmap();
console.log('gpuReadBuffer.unmap()');
};

await gpu_run(DEV,device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer);

console.log('erstes gpu_run ist durch');
console.log('');

// Read buffer.


//♦erste Matrix direkt modifizieren
firstMatrix[2]=-100;
console.log('firstMatrix[2]='+firstMatrix[2]);

//zweite Matrix direkt modifizieren
secondMatrix[9]=88888;
console.log('secondMatrix[9]='+secondMatrix[9]);

await gpu_run(DEV,device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer);

console.log('zweites gpu_run ist durch');
console.log('');

// Read buffer.

//♦erste Matrix nochmal modifizieren
for (let i=2;i<firstMatrix.length;i++) firstMatrix[i]=firstMatrix[i]*-1.0;
console.log('firstMatrix[2]='+firstMatrix[2]);

//zweite Matrix nochmal modifizieren
//secondMatrix[9]=-88888;
console.log('secondMatrix[9]='+secondMatrix[9]);

await gpu_run(DEV,device,bindGroupLayout,bindGroup,shaderModule,gpuWriteFirstMatrix,gpuBufferFirstMatrix,gpuWriteSecondMatrix,gpuBufferSecondMatrix,resultMatrixBuffer,gpuReadBuffer);

console.log('drittes gpu_run ist durch');
console.log('');

// Read buffer.

console.log('/script');
