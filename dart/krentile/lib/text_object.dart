/**
 * Copyright (c) 2015 Albert Murciego Rico
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

class TextObject extends CommonObject {
  
  TileSet _tileSet;
  
  String _text;
  
  WebGL.Buffer _vertexBuffer;
  WebGL.Buffer _indexBuffer;

  int _vertexCount;
  int _vertexStride;

  TextObject.data(this._tileSet, int x, int y,
      bool visible, this._text) {
    _x = x;
    _y = y;
    
    _visible = visible;
  }
  
  TileSet get tileSet => _tileSet;
  void set tileSet(TileSet tileSet) {
    _tileSet = tileSet;
  }
  
  String get text => _text;
  void set text(String text) {
    _text = text;
  }
  
  void cleanUp(WebGL.RenderingContext renderingContext) {
    if (_vertexBuffer != null) {
      renderingContext.deleteBuffer(_vertexBuffer);
    }

    if (_indexBuffer != null) {
      renderingContext.deleteBuffer(_indexBuffer);
    }
  }

  /**
   * draw
   * TODO
   */
  void draw(WebGL.RenderingContext renderingContext, Float32List cameraTransform,
            double cameraOffsetX, double cameraOffsetY) {
    
    double offsetX = _x + cameraOffsetX;
    double offsetY = _y + cameraOffsetY;

    // Bind texture
    TextureManager.instance.bind(_tileSet.image, renderingContext);
    
    // Bind buffers
    renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.enableVertexAttribArray(ShaderManager.instance.positionAttributeIndex);
    renderingContext.vertexAttribPointer(ShaderManager.instance.positionAttributeIndex,
        2, WebGL.RenderingContext.FLOAT, false, _vertexStride, 0);

    renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.enableVertexAttribArray(ShaderManager.instance.textureAttributeIndex);
    renderingContext.vertexAttribPointer(ShaderManager.instance.textureAttributeIndex,
        2, WebGL.RenderingContext.FLOAT, false, _vertexStride, 8);

    renderingContext.useProgram(ShaderManager.instance.program);
    renderingContext.uniformMatrix4fv(ShaderManager.instance.cameraTransform, false, cameraTransform);
    renderingContext.uniform2f(ShaderManager.instance.positionOffset, offsetX, offsetY);
    renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.drawElements(WebGL.RenderingContext.TRIANGLES,
        _vertexCount, WebGL.RenderingContext.UNSIGNED_SHORT, 0);
    
  }
  
  void updateBuffers(WebGL.RenderingContext renderingContext) {
    
    int textLength = _text.length;
    
    List vertexPositions = new List();
    List vertexTextureCoords = new List();
    List indices = new List();
    int tileCount = 0;

    for (int i = 0; i < textLength; ++i) {
      int tileIndex = _text.codeUnitAt(i) - 32;
      Tile tile = _tileSet.tiles[tileIndex];
      
      double tileSizeWith = tile.withPixels;
      double tileSizeHeight = tile.heightPixels;

      vertexPositions
          ..add(((i + 1) * tileSizeWith))
          ..add(0.0)
          ..add(((i + 1) * tileSizeWith))
          ..add(tileSizeHeight)
          ..add((i * tileSizeWith))
          ..add(tileSizeHeight)
          ..add((i * tileSizeWith))
          ..add(0.0);

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

    // Bind vertex buffer

    var vertexData = new Float32List(vertexPositions.length + vertexTextureCoords.length);

    int writeCursor = 0;
    for (int i = 0; (i * 2) < vertexPositions.length; ++i) {
      vertexData[writeCursor++] = vertexPositions[i * 2];
      vertexData[writeCursor++] = vertexPositions[i * 2 + 1];
      vertexData[writeCursor++] = vertexTextureCoords[i * 2];
      vertexData[writeCursor++] = vertexTextureCoords[i * 2 + 1];
    }
    
    if (_vertexBuffer != null) {
      renderingContext.deleteBuffer(_vertexBuffer);
    }

    _vertexBuffer = renderingContext.createBuffer();
    renderingContext.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, vertexData, 
        WebGL.RenderingContext.STATIC_DRAW);

    // Bind index buffer

    var indexData = new Uint16List.fromList(indices);
    
    if (_indexBuffer != null) {
      renderingContext.deleteBuffer(_indexBuffer);
    }

    _indexBuffer = renderingContext.createBuffer();
    renderingContext.bindBuffer(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bufferDataTyped(WebGL.RenderingContext.ELEMENT_ARRAY_BUFFER, indexData, 
        WebGL.RenderingContext.STATIC_DRAW);

    _vertexCount = indices.length;
    _vertexStride = 16; // (4 * (2 + 2)) -- 4 floats per vertex
    
  }
  
}
