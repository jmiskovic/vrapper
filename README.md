# VRapper

Various VR experiments made using LÖVR framework for VR. Uses Lua code for procedural world generation and graphics. No imported meshes, all geometry is computed.

The avatar code implements hands as physical objects synchronized with real world controllers, relative position/orientation in VR, and locomotion using standard thumbstick and teleportation mechanics. While real-world motion is synchronized to VR, the teleportation is not synchronized to real world.

Physics code is convenience wrapper for LÖVR (ODE) physics for easier instantiation and rendering of primitives (box, and ball), and for ray-casting with distance-sorted results.

There are several example scenes that use this common functionality.
