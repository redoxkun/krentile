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

class SceneObjectType {
  
  TileSet _tileSet;

  int _tileSize;
  
  List<List<int>> _states;
  
  List<WebGL.Buffer> _vertexBuffers;
  List<WebGL.Buffer> _indexBuffers;

  List<int> _vertexCounts;
  List<int> _vertexStrides;
  
  SceneObjectType() {
    _vertexBuffers = new List<WebGL.Buffer>();
    _indexBuffers = new List<WebGL.Buffer>();
    _vertexCounts = new List<int>();
    _vertexStrides = new List<int>();
  }
  
  /**
   * loadFromString
   * TODO
   */
  void loadFromString(String objectType, Map<String, TileSet> tileSets, WebGL.RenderingContext renderingContext) {
    var jsonObjectType = JSON.decode(objectType);
    loadFromJson(jsonObjectType, tileSets, renderingContext);
  }

  /**
   * loadFromJson
   * TODO
   */
  void loadFromJson(var objectType, Map<String, TileSet> tileSets, WebGL.RenderingContext renderingContext) {

    _tileSize = objectType['tileSize'];
    
    _tileSet = tileSets[objectType['tileSet']];
    
    _states = objectType['states'];

    List tilemaps = objectType['tilemaps'];

    _buildBuffers(tilemaps, renderingContext);
  }

  /**
   * draw
   * TODO
   */
  void draw(WebGL.RenderingContext renderingContext, Float32List cameraTransform, SceneObject object) {
    
    int state = _states[object.state][object.frame];
    
    WebGL.Buffer vertexBuffer = _vertexBuffers[state];
    WebGL.Buffer indexBuffer = _indexBuffers[state];
    int vertexCount = _vertexCounts[state];
    int vertexStride = _vertexStrides[state];

    // Bind texture
    TextureManager.instance.bind(_tileSet.image, renderingContext);
    
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
    renderingContext.uniform2f(ShaderManager.instance.positionOffset, object.x, object.y);
    renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    renderingContext.drawElements(WebGL.RenderingContext.TRIANGLES,
        vertexCount, WebGL.RenderingContext.UNSIGNED_SHORT, 0);
    
    if (object.autoAnimation) {
      if (object.advanceFrame) {
        object.frame++;
        if (object.frame >= _states[object.state].length) {
          object.frame = 0;
        }
      } else {
        object.advanceDraw();
      }
    }
  }

  void _buildBuffers(List tilemaps, WebGL.RenderingContext renderingContext) {
    
    _vertexBuffers.clear();
    _indexBuffers.clear();
    _vertexCounts.clear();
    _vertexStrides.clear();
    
    for (List tilemap in tilemaps) {
      
      List vertexPositions = new List();
      List vertexTextureCoords = new List();
      List indices = new List();
      int tileCount = 0;
  
      for (int j = 0; j < tilemap.length; ++j) {
        for (int i = 0; i < tilemap[j].length; ++i) {
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
      renderingContext.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, vertexData, 
          WebGL.RenderingContext.STATIC_DRAW);
  
      // Bind index buffer
  
      var indexData = new Uint16List.fromList(indices);
  
      WebGL.Buffer indexBuffer = renderingContext.createBuffer();
      renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
      renderingContext.bufferDataTyped(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexData, 
          WebGL.RenderingContext.STATIC_DRAW);
  
      int vertexCount = indices.length;
      int vertexStride = 16; // (4 * (2 + 2)) -- 4 floats per vertex
      
      _vertexBuffers.add(vertexBuffer);
      _indexBuffers.add(indexBuffer);
      _vertexCounts.add(vertexCount);
      _vertexStrides.add(vertexStride);
    }
    
  }
  
}
