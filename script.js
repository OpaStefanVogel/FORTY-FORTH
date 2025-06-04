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

  new Uint8Array(arrayBuffer).set([0, 1, 2, 3]);
  
console.log('arrayBuffer ist gefüllt.');

  gpuWriteBuffer.unmap();

console.log('gpuWriteBuffer.unmap()');


})();
console.log('/script')
