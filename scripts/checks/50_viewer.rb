# frozen_string_literal: true

model_page = '/3d/example-model/'
expect_match(model_page, %r{<model-viewer[^>]*src="/assets/3d/example-model/model\.glb"}, 'viewer with the model file')
expect_match(model_page, /<model-viewer[^>]*camera-controls/, 'camera controls')
expect_match(model_page, /<model-viewer[^>]*auto-rotate/, 'auto rotate')
expect_match(model_page, %r{<model-viewer[^>]*poster="/assets/3d/example-model/1\.svg"}, 'cover as poster')
expect_match(model_page, %r{src="https://cdn\.jsdelivr\.net/npm/@google/model-viewer@4\.0\.0/dist/model-viewer\.min\.js"}, 'viewer script')
expect_match(model_page, %r{href="/assets/3d/example-model/model\.glb" download>Download \.glb</a>}, 'download link')

glb = File.join(SITE, 'assets/3d/example-model/model.glb')
FAILURES << 'model.glb: not a binary glTF file' unless File.file?(glb) && File.binread(glb, 4) == 'glTF'
