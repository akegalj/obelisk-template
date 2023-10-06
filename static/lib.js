// Accessing the property via string literal prevents renaming by javascript minifiers which can cause FFI errors
window['skeleton_lib'] = {
  animationHook: f => {
    // console.log("wooo"); f(2); f(3); requestAnimationFrame(f); 
    var animation = d => {
      f(d);
      requestAnimationFrame(animation);
    };
    requestAnimationFrame(animation);
  },
};
