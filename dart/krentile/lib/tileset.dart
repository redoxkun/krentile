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

class TileSet {
  
  String _image;
  
  int _width;
  int _height;
  
  List<Tile> _tiles;
  
  TileSet() {
    _tiles = new List<Tile>();
  }
  
  /**
   * loadFromString
   * TODO
   */
  Future loadFromString(String tileSet, WebGL.RenderingContext renderingContext) {
    var jsonTileSet = JSON.decode(tileSet);
    return loadFromJson(jsonTileSet, renderingContext);
  }

  /**
   * loadFromJson
   * TODO
   */
  Future loadFromJson(var tileSet, WebGL.RenderingContext renderingContext) {
    _image = tileSet['image'];

    Future future = TextureManager.instance.load(_image, renderingContext);
    
    _width = tileSet['width'];
    _height = tileSet['height'];
    
    _tiles.clear();
    
    for (var jsonTile in tileSet['tiles']) {
      Tile tile = new Tile(jsonTile['left'] / _width,
                           jsonTile['top'] / _height,
                           jsonTile['right'] / _width,
                           jsonTile['bottom'] / _height);
      _tiles.add(tile);
    }
    
    return future;
  }
  
  String get image => _image;
  
  List<Tile> get tiles => _tiles;
  
}
