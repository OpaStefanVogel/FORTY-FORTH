//Quelle: https://developer.chrome.com/docs/capabilities/web-apis/gpu-compute
let Logbit_gpu=false;
let console={log:function(arg) {if (Logbit_gpu) Log_gpu.innerHTML=Log_gpu.innerHTML+'\n'+arg},info:function(arg) {Log_gpu.innerHTML=Log_gpu.innerHTML+'\n'+arg}};
console.log('script');

window.onerror=function(message, file, line, col, error) {console.info('<span style="color:red">ERROR</span> message '+message+'\nfile: '+file+'\nline: '+line+'\ncol: '+col+'\nerror: '+error+'\n\n')};
window.addEventListener('error',function(arg) {console.info('<span style="color:red">ERROR ERROR</span> message '+arg.error.message+' '+arg.error.name); for (let i of arg.error) console.log(i)});
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

async function gpu_init(DEV) { 
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


const gpuWriteFirstMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: DEV.firstMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC
});

const gpuBufferFirstMatrix = device.createBuffer({
  size: DEV.firstMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
});

const gpuWriteSecondMatrix = device.createBuffer({
  mappedAtCreation: true,
  size: DEV.secondMatrix.byteLength,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC,
});

const gpuBufferSecondMatrix = device.createBuffer({
  size: DEV.secondMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
});

//const resultMatrixBufferSize = Float32Array.BYTES_PER_ELEMENT * (2 + DEV.firstMatrix[0] * DEV.secondMatrix[1]);
const resultMatrixBuffer = device.createBuffer({
  mappedAtCreation: true,
  size: DEV.resultMatrix.byteLength,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
});

const arrayBufferResultMatrix = resultMatrixBuffer.getMappedRange();
new Float32Array(arrayBufferResultMatrix).set(DEV.resultMatrix);
resultMatrixBuffer.unmap();
console.log('resultMatrixBuffer ist gefüllt:'+resultMatrixBuffer);

// Get a GPU buffer for reading in an unmapped state.
const gpuReadBuffer = device.createBuffer({
  size: DEV.resultMatrix.byteLength,
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

//      resultMatrix.size = vec2(firstMatrix.size.x, secondMatrix.size.y);

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



//folgendes wird alles gebraucht in gpu_run:
DEV.device=device;
DEV.bindGroupLayout=bindGroupLayout;
DEV.bindGroup=bindGroup;
DEV.shaderModule=shaderModule;
DEV.computePipeline = computePipeline;
DEV.gpuWriteFirstMatrix=gpuWriteFirstMatrix;
DEV.gpuBufferFirstMatrix=gpuBufferFirstMatrix;
DEV.gpuWriteSecondMatrix=gpuWriteSecondMatrix;
DEV.gpuBufferSecondMatrix=gpuBufferSecondMatrix;
DEV.resultMatrixBuffer=resultMatrixBuffer;
DEV.gpuReadBuffer=gpuReadBuffer;

}

await gpu_init(DEV);
console.log(DEV.device);



async function gpu_run(DEV) {
console.log('DEV.firstMatrix=['+DEV.firstMatrix+'];');
console.log('DEV.secondMatrix=['+DEV.secondMatrix+'];');

let arrayBufferFirstMatrix = DEV.gpuWriteFirstMatrix.getMappedRange();
new Float32Array(arrayBufferFirstMatrix).set(DEV.firstMatrix);
DEV.gpuWriteFirstMatrix.unmap();
console.log('dann .set(firstMatrix) und .unmap()');

let arrayBufferSecondMatrix = DEV.gpuWriteSecondMatrix.getMappedRange();
new Float32Array(arrayBufferSecondMatrix).set(DEV.secondMatrix);
DEV.gpuWriteSecondMatrix.unmap();
console.log('dann .set(secondMatrix) und .unmap()');

//DEV.gpuReadBuffer.unmap();
DEV.gpuReadBuffer.unmap();
console.log('DEV.gpuReadBuffer.unmap()');


let commandEncoder = DEV.device.createCommandEncoder();

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  DEV.gpuWriteFirstMatrix,
  0,
  DEV.gpuBufferFirstMatrix,
  0,
  firstMatrix.byteLength
);

// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  DEV.gpuWriteSecondMatrix,
  0,
  DEV.gpuBufferSecondMatrix,
  0,
  secondMatrix.byteLength
);

let passEncoder = commandEncoder.beginComputePass();
passEncoder.setPipeline(DEV.computePipeline);
passEncoder.setBindGroup(0, DEV.bindGroup);
const workgroupCountX = Math.ceil(firstMatrix[0] / 8);
const workgroupCountY = Math.ceil(secondMatrix[1] / 8);
passEncoder.dispatchWorkgroups(workgroupCountX, workgroupCountY);
passEncoder.end();

console.log('passEncoder.end wie auch immer:'+passEncoder);
console.log('mit Math.ceil(firstMatrix[0] / 8)='+Math.ceil(firstMatrix[0] / 8));


// Encode commands for copying buffer to buffer.
commandEncoder.copyBufferToBuffer(
  DEV.resultMatrixBuffer,
  0,
  DEV.gpuReadBuffer,
  0,
  resultMatrix.byteLength
);

// Submit GPU commands.
let gpuCommands = commandEncoder.finish();
DEV.device.queue.submit([gpuCommands]);

await DEV.gpuReadBuffer.mapAsync(GPUMapMode.READ);
let arrayBuffer = DEV.gpuReadBuffer.getMappedRange();
DEV.Ergebnis=new Float32Array(arrayBuffer);
console.log(DEV.Ergebnis);

console.log('Versuch await DEV.gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);');
await DEV.gpuWriteFirstMatrix.mapAsync(GPUMapMode.WRITE);
console.log('Versuch await DEV.gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);');
await DEV.gpuWriteSecondMatrix.mapAsync(GPUMapMode.WRITE);
};

await gpu_run(DEV);

// Read buffer.
console.info('erstes gpu_run ist durch: '+DEV.Ergebnis);
console.log('');


//♦erste Matrix direkt modifizieren
DEV.firstMatrix[2]=-100;
console.log('DEV.firstMatrix[2]='+DEV.firstMatrix[2]);

//zweite Matrix direkt modifizieren
DEV.secondMatrix[9]=88888;
console.log('DEV.secondMatrix[9]='+DEV.secondMatrix[9]);

await gpu_run(DEV);

// Read buffer.
console.info('zweites gpu_run ist durch: '+DEV.Ergebnis);
console.log('');


//♦erste Matrix nochmal modifizieren
for (let i=2;i<DEV.firstMatrix.length;i++) DEV.firstMatrix[i]=-DEV.firstMatrix[i];
console.log('DEV.firstMatrix[2]='+DEV.firstMatrix[2]);

//zweite Matrix nochmal modifizieren
//secondMatrix[9]=-88888;
//console.log('secondMatrix[9]='+secondMatrix[9]);

await gpu_run(DEV);

// Read buffer.
console.info('drittes gpu_run ist durch: '+DEV.Ergebnis);
console.log('');

console.log('/script');
