//Quelle: https://developer.chrome.com/docs/capabilities/web-apis/gpu-compute
let console={log:function(arg) {Log1.innerHTML=Log1.innerHTML+'\n'+arg}};
console.log('script');

(async () => {
  if (!("gpu" in navigator)) {
    alert( "WebGPU is not supported. Enable chrome://flags/#enable-unsafe-webgpu flag." );
    return;
  } else console.log('drin');

  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) {
    console.log("Failed to get GPU adapter.");
    return;
  }
  const device = await adapter.requestDevice();

console.log('device ist da');

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
    gpuWriteBuffer /* source buffer */,
    0 /* source offset */,
    gpuReadBuffer /* destination buffer */,
    0 /* destination offset */,
    4 /* size */
    );
    
console.log('copyEncoder ist erzeugt und gefüllt: '+copyEncoder);

  const copyCommands = copyEncoder . finish();
  device . queue . submit ( [ copyCommands ] ) ;
console.log('copyCommands ist erzeugt und ausgeführt: '+copyCommands);

  await gpuReadBuffer . mapAsync ( GPUMapMode . READ ) ;

console.log('await gpuReadBuffer . mapAsync ');

  const copyArrayBuffer = gpuReadBuffer . getMappedRange ( ) ;

console.log('copyArrayBuffer ist erzeugt: '+copyArrayBuffer);

console.log('Ergebnis: '+(new Uint8Array ( copyArrayBuffer) ) ) ;


})();
console.log('/script')
