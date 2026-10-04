"""Writes a 20 mm cube as a binary glTF (GLB) file: python3 scripts/make_cube_glb.py OUT.glb"""
import json
import struct
import sys

HALF = 0.01  # half edge in metres

positions, normals, indices = [], [], []
for axis in range(3):
    for sign in (1, -1):
        normal = [0.0, 0.0, 0.0]
        normal[axis] = float(sign)
        u = [0.0, 0.0, 0.0]
        u[(axis + 1) % 3] = 1.0
        v = [0.0, 0.0, 0.0]
        v[(axis + 2) % 3] = 1.0
        corners = [
            [normal[i] * HALF + HALF * (a * u[i] + b * v[i]) for i in range(3)]
            for a, b in ((-1, -1), (1, -1), (1, 1), (-1, 1))
        ]
        if sign < 0:
            corners.reverse()  # keep the winding counter-clockwise seen from outside
        base = len(positions)
        positions += corners
        normals += [normal] * 4
        indices += [base, base + 1, base + 2, base, base + 2, base + 3]

pos_bytes = b"".join(struct.pack("<3f", *p) for p in positions)
nrm_bytes = b"".join(struct.pack("<3f", *n) for n in normals)
idx_bytes = struct.pack(f"<{len(indices)}H", *indices)
binary = pos_bytes + nrm_bytes + idx_bytes
binary += b"\0" * (-len(binary) % 4)

gltf = {
    "asset": {"version": "2.0", "generator": "make_cube_glb.py"},
    "scene": 0,
    "scenes": [{"nodes": [0]}],
    "nodes": [{"mesh": 0}],
    "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1}, "indices": 2, "material": 0}]}],
    "materials": [{"pbrMetallicRoughness": {"baseColorFactor": [0.11, 0.31, 0.85, 1.0], "metallicFactor": 0.0, "roughnessFactor": 0.6}}],
    "buffers": [{"byteLength": len(binary)}],
    "bufferViews": [
        {"buffer": 0, "byteOffset": 0, "byteLength": len(pos_bytes), "target": 34962},
        {"buffer": 0, "byteOffset": len(pos_bytes), "byteLength": len(nrm_bytes), "target": 34962},
        {"buffer": 0, "byteOffset": len(pos_bytes) + len(nrm_bytes), "byteLength": len(idx_bytes), "target": 34963},
    ],
    "accessors": [
        {"bufferView": 0, "componentType": 5126, "count": len(positions), "type": "VEC3", "min": [-HALF] * 3, "max": [HALF] * 3},
        {"bufferView": 1, "componentType": 5126, "count": len(normals), "type": "VEC3"},
        {"bufferView": 2, "componentType": 5123, "count": len(indices), "type": "SCALAR"},
    ],
}
json_bytes = json.dumps(gltf, separators=(",", ":")).encode()
json_bytes += b" " * (-len(json_bytes) % 4)

total = 12 + 8 + len(json_bytes) + 8 + len(binary)
with open(sys.argv[1], "wb") as out:
    out.write(struct.pack("<III", 0x46546C67, 2, total))
    out.write(struct.pack("<II", len(json_bytes), 0x4E4F534A) + json_bytes)
    out.write(struct.pack("<II", len(binary), 0x004E4942) + binary)
