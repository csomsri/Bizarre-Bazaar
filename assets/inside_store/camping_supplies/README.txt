LOW POLY CAMPING & SURVIVAL PACK - 85 models
============================================
FBX/      one file per model + _AllProps.fbx (T_Palette.png embedded)
GLB/      one file per model + _AllProps.glb (glTF 2.0)
OBJ/      _AllProps.obj + .mtl
T_Palette.png                 shared palette texture (every model uses it)
LowPoly_Camping_Pack.blend    all models (Blender 5.2)
Demo_Campsite_Scene.blend     demo campsite scene

Materials: M_Palette and M_Palette_Emissive (campfire, lantern). In other engines assign
T_Palette.png as Base Color (and as Emission on the emissive one).
Scale: 1 unit = 1 m.

Unity / Unreal / Godot (v1.1, 2026-11-03)
  Every model has a single UV map (the palette UV) and the FBX files have T_Palette.png
  embedded, so models import with their full colours. In Unity, select an FBX and use
  Materials > Extract Textures / Extract Materials if you want editable copies.
  GLB in Unity needs the glTFast or UnityGLTF package.
  v1.1 fixes FBX/GLB showing a single colour in Unity (an extra UV map was exported first).

Licence: use in personal and commercial projects. Do not resell or redistribute the models as assets.
Made with AI assistance (procedural Blender Python scripts, reviewed by hand).
