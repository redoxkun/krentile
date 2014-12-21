/**
 * Copyright (c) 2014 Albert Murciego Rico
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

part of krentile;

class Layer {

  final int _width;
  final int _height;
  
  int _halfWidth;
  int _halfHeight;

  double _speedX;
  double _speedY;

  int _tileSize;
  
  List<int> _objectIndices;

  int _chunkWidthTiles;
  int _chunkHeightTiles;

  int _mapWidthTiles;
  int _mapHeightTiles;
  
  int _widthChunks;
  int _heightChunks;
  
  Camera _startCamera;

  TileSet _tileSet;

  List<List<WebGL.Buffer>> _vertexBuffers;
  List<List<WebGL.Buffer>> _indexBuffers;

  List<List<int>> _vertexCounts;
  List<List<int>> _vertexStrides;

  Layer(this._width, this._height) {
    
    _halfWidth = _width ~/ 2;
    _halfHeight = _height ~/ 2;
    
    _startCamera = new Camera();
    
    _vertexBuffers = new List<List<WebGL.Buffer>>();
    _indexBuffers = new List<List<WebGL.Buffer>>();
    _vertexCounts = new List<List<int>>();
    _vertexStrides = new List<List<int>>();
  }

  /**
   * loadFromString
   * TODO
   */
  void loadFromString(String layer, Map<String, TileSet> tileSets, WebGL.RenderingContext renderingContext) {
    var jsonLayer = JSON.decode(layer);
    loadFromJson(jsonLayer, tileSets, renderingContext);
  }

  /**
   * loadFromJson
   * TODO
   */
  void loadFromJson(var layer, Map<String, TileSet> tileSets, WebGL.RenderingContext renderingContext) {
    _speedX = layer['speedX'];
    _speedY = layer['speedY'];

    _tileSize = layer['tileSize'];

    _chunkWidthTiles = (_width / _tileSize).ceil();
    _chunkHeightTiles = (_height / _tileSize).ceil();
    
    List tilemap = layer['tilemap'];

    _mapWidthTiles = layer['tilemap'][0].length;
    _mapHeightTiles = layer['tilemap'].length;

    _widthChunks = (_mapWidthTiles / _chunkWidthTiles).ceil();
    _heightChunks = (_mapHeightTiles / _chunkHeightTiles).ceil();

    _tileSet = tileSets[layer['tileSet']];
    
    _objectIndices = layer['objects'];

    _buildBuffers(tilemap, renderingContext);
  }

  /**
   * draw
   * TODO
   */
  void draw(WebGL.RenderingContext renderingContext, Float32List cameraTransform, Camera camera, 
            List<SceneObjectType> objectTypes, List<SceneObject> objects) {
    
    int xMin = camera.x - _halfWidth;
    int xMax = camera.x + _halfWidth;
    
    int yMin = camera.y - _halfHeight;
    int yMax = camera.y + _halfHeight;
    
    double offsetX = (camera.x - _startCamera.x) - (camera.x - _startCamera.x) * _speedX;
    double offsetY = (camera.y - _startCamera.y) - (camera.y - _startCamera.y) * _speedY;

    // Bind texture
    TextureManager.instance.bind(_tileSet.image, renderingContext);
    
    for (int jChunk = 0; jChunk < _heightChunks; ++jChunk) {

      for (int iChunk = 0; iChunk < _widthChunks; ++iChunk) {
        
        if (((iChunk * _width >= xMin && iChunk * _width < xMax) || 
            ((iChunk +1) * _width >= xMin && (iChunk +1) * _width < xMax)) &&
            ((jChunk * _height >= yMin && jChunk * _height < yMax) ||
            ((jChunk +1) * _height >= yMin && (jChunk +1) * _height < yMax))) {
        
          WebGL.Buffer vertexBuffer = _vertexBuffers[jChunk][iChunk];
          WebGL.Buffer indexBuffer = _indexBuffers[jChunk][iChunk];
          
          int vertexStride = _vertexStrides[jChunk][iChunk];
          int vertexCount = _vertexCounts[jChunk][iChunk];
  
          // Bind buffers
          renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, vertexBuffer);
          renderingContext.enableVertexAttribArray(ShaderManager.instance.positionAttributeIndex);
          renderingContext.vertexAttribPointer(ShaderManager.instance.positionAttributeIndex,
              2, WebGL.RenderingContext.FLOAT, false, vertexStride, 0);
      
          renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, vertexBuffer);
          renderingContext.enableVertexAttribArray(ShaderManager.instance.textureAttributeIndex);
          renderingContext.vertexAttribPointer(ShaderManager.instance.textureAttributeIndex,
              2, WebGL.RenderingContext.FLOAT, false, vertexStride, 8);
      
          renderingContext.useProgram(ShaderManager.instance.program);
          renderingContext.uniformMatrix4fv(ShaderManager.instance.cameraTransform, false, cameraTransform);
          renderingContext.uniform2f(ShaderManager.instance.positionOffset, offsetX, offsetY);
          renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
          renderingContext.drawElements(WebGL.RenderingContext.TRIANGLES,
              vertexCount, WebGL.RenderingContext.UNSIGNED_SHORT, 0);
        }
        
      }
      
    }

    _objectIndices.sort((int a, int b) {
      return objects[a].y - objects[b].y;
    });
    
    for (int objectIndex in _objectIndices) {
      SceneObject object = objects[objectIndex];
      if (object.visible) {
        // TODO: Check if is in the viewport
        objectTypes[object.type].draw(renderingContext, cameraTransform, object);
      }
    }

  }
  
  void set startCamera(Camera camera) {
    _startCamera.x = camera.x;
    _startCamera.y = camera.y;
  }

  void _buildBuffers(List tilemap, WebGL.RenderingContext renderingContext) {
    
    _vertexBuffers.clear();
    _indexBuffers.clear();
    
    _vertexCounts.clear();
    _vertexStrides.clear();
    
    for (int jChunk = 0; jChunk < _heightChunks; ++jChunk) {
      List<WebGL.Buffer> vertexBuffersRow = new List<WebGL.Buffer>();
      List<WebGL.Buffer> indexBuffersRow = new List<WebGL.Buffer>();
      
      List<int> vertexCountsRow = new List<int>();
      List<int> vertexStridesRow = new List<int>();

      int currentChunkHeightTiles = _chunkHeightTiles;
      
      if (((jChunk + 1) * _chunkHeightTiles) > _mapHeightTiles) {
        currentChunkHeightTiles = _chunkHeightTiles + (_mapHeightTiles - ((jChunk + 1) * _chunkHeightTiles));
      }
      
      int startJChunk = jChunk * _chunkHeightTiles;
      int endJChunk = startJChunk + currentChunkHeightTiles;
      
      for (int iChunk = 0; iChunk < _widthChunks; ++iChunk) {
        
        int currentChunkWidthTiles = _chunkWidthTiles;
        
        if (((iChunk + 1) * _chunkWidthTiles) > _mapWidthTiles) {
          currentChunkWidthTiles = _chunkWidthTiles + (_mapWidthTiles - ((iChunk + 1) * _chunkWidthTiles));
        }

        int startIChunk = iChunk * _chunkWidthTiles;
        int endIChunk = startIChunk + currentChunkWidthTiles;
        
        List vertexPositions = new List();
        List vertexTextureCoords = new List();
        List indices = new List();
        int tileCount = 0;
    
        for (int j = startJChunk; j < endJChunk; ++j) {
          for (int i = startIChunk; i < endIChunk; ++i) {
            vertexPositions
                ..add(((i + 1) * _tileSize).toDouble())
                ..add((j * _tileSize).toDouble())
                ..add(((i + 1) * _tileSize).toDouble())
                ..add(((j + 1) * _tileSize).toDouble())
                ..add((i * _tileSize).toDouble())
                ..add(((j + 1) * _tileSize).toDouble())
                ..add((i * _tileSize).toDouble())
                ..add((j * _tileSize).toDouble());
    
            Tile tile = _tileSet.tiles[tilemap[j][i]];
            vertexTextureCoords
                ..add(tile.right)
                ..add(tile.top)
                ..add(tile.right)
                ..add(tile.bottom)
                ..add(tile.left)
                ..add(tile.bottom)
                ..add(tile.left)
                ..add(tile.top);
    
            indices
                ..add(4 * tileCount)
                ..add(4 * tileCount + 1)
                ..add(4 * tileCount + 2)
                ..add(4 * tileCount)
                ..add(4 * tileCount + 2)
                ..add(4 * tileCount + 3);
    
            tileCount++;
          }
        }
        
        // Bind vertex buffer
    
        var vertexData = new Float32List(vertexPositions.length + vertexTextureCoords.length);
    
        int writeCursor = 0;
        for (int i = 0; (i * 2) < vertexPositions.length; ++i) {
          vertexData[writeCursor++] = vertexPositions[i * 2];
          vertexData[writeCursor++] = vertexPositions[i * 2 + 1];
          vertexData[writeCursor++] = vertexTextureCoords[i * 2];
          vertexData[writeCursor++] = vertexTextureCoords[i * 2 + 1];
        }
    
        WebGL.Buffer vertexBuffer = renderingContext.createBuffer();
        renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, vertexBuffer);
        renderingContext.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, vertexData, WebGL.RenderingContext.STATIC_DRAW);
    
        // Bind index buffer
    
        var indexData = new Uint16List.fromList(indices);
    
        WebGL.Buffer indexBuffer = renderingContext.createBuffer();
        renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
        renderingContext.bufferDataTyped(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexData, WebGL.RenderingContext.STATIC_DRAW);

        int vertexCount = indices.length;
        int vertexStride = 16; // (4 * (2 + 2)) -- 4 floats per vertex
        
        vertexBuffersRow.add(vertexBuffer);
        indexBuffersRow.add(indexBuffer);
        
        vertexCountsRow.add(vertexCount);
        vertexStridesRow.add(vertexStride);
        
        
      }
      _vertexBuffers.add(vertexBuffersRow);
      _indexBuffers.add(indexBuffersRow);

      _vertexCounts.add(vertexCountsRow);
      _vertexStrides.add(vertexStridesRow);
    }

  }

}
