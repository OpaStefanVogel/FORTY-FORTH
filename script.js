//Quelle: https://developer.chrome.com/docs/capabilities/web-apis/gpu-compute
alert(8);
let console={log:function(arg) {alert(arg)}};
console.log(7);

(async () => {
  if (!("gpu" in navigator)) {
    alert( "WebGPU is not supported. Enable chrome://flags/#enable-unsafe-webgpu flag." );
    return;
  } else alert('drin');

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
console.log('gpuWriteBuffer ist da');
console.log(gpuWriteBuffer.getMappedRange);
  const arrayBuffer = gpuWriteBuffer.getMappedRange();
​
console.log('arrayBuffer ist da');//funktioniert aber nicht

})();
alert(9);
