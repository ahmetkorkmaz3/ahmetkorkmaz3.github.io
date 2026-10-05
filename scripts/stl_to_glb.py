"""Converts a binary STL file (mm, z up) to a binary glTF (GLB) file (m, y up).

python3 scripts/stl_to_glb.py IN.stl OUT.glb [R G B]

The color is in the range 0 to 1. Each triangle gets its own vertices, so the faces look flat.
"""
import json
import struct
import sys

MM = 0.001  # STL units are millimetres, glTF units are metres

data = open(sys.argv[1], "rb").read()
count = struct.unpack_from("<I", data, 80)[0]
if len(data) != 84 + 50 * count:
    sys.exit(f"{sys.argv[1]}: not a binary STL file")
color = [float(c) for c in sys.argv[3:6]] or [0.02, 0.12, 0.75]

positions, normals = [], []
for t in range(count):
    values = struct.unpack_from("<12f", data, 84 + 50 * t)
    # glTF is y up: STL (x, y, z) becomes (x, z, -y).
    corners = [(values[i] * MM, values[i + 2] * MM, -values[i + 1] * MM) for i in (3, 6, 9)]
    a, b, c = corners
    u = [b[i] - a[i] for i in range(3)]
    v = [c[i] - a[i] for i in range(3)]
    n = [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
    length = sum(x * x for x in n) ** 0.5 or 1.0
    positions += corners
    normals += [[x / length for x in n]] * 3

pos_bytes = b"".join(struct.pack("<3f", *p) for p in positions)
nrm_bytes = b"".join(struct.pack("<3f", *n) for n in normals)
binary = pos_bytes + nrm_bytes

gltf = {
    "asset": {"version": "2.0", "generator": "stl_to_glb.py"},
    "scene": 0,
    "scenes": [{"nodes": [0]}],
    "nodes": [{"mesh": 0}],
    "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1}, "material": 0}]}],
    "materials": [{"pbrMetallicRoughness": {"baseColorFactor": color + [1.0], "metallicFactor": 0.0, "roughnessFactor": 0.6}}],
    "buffers": [{"byteLength": len(binary)}],
    "bufferViews": [
        {"buffer": 0, "byteOffset": 0, "byteLength": len(pos_bytes), "target": 34962},
        {"buffer": 0, "byteOffset": len(pos_bytes), "byteLength": len(nrm_bytes), "target": 34962},
    ],
    "accessors": [
        {
            "bufferView": 0, "componentType": 5126, "count": len(positions), "type": "VEC3",
            "min": [min(p[i] for p in positions) for i in range(3)],
            "max": [max(p[i] for p in positions) for i in range(3)],
        },
        {"bufferView": 1, "componentType": 5126, "count": len(normals), "type": "VEC3"},
    ],
}
json_bytes = json.dumps(gltf, separators=(",", ":")).encode()
json_bytes += b" " * (-len(json_bytes) % 4)

total = 12 + 8 + len(json_bytes) + 8 + len(binary)
with open(sys.argv[2], "wb") as out:
    out.write(struct.pack("<III", 0x46546C67, 2, total))
    out.write(struct.pack("<II", len(json_bytes), 0x4E4F534A) + json_bytes)
    out.write(struct.pack("<II", len(binary), 0x004E4942) + binary)
