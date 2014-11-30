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

class Scene {
  
  List<Layer> _layers;
  Map<String, TileSet> _tileSets;
  List<SceneObject> _objects;
  List<SceneObjectType> _objectTypes;
  
  int _tileSize;
  List<List<int>> _events;
  
  int _width;
  int _height;
  
  List<double> _backgroundColor;
  
  Camera _camera;
  
  Scene() {
    _init();
  }
  
  void _init() {
    _layers = new List<Layer>();
    _tileSets = new Map<String, TileSet>();
    _objects = new List<SceneObject>();
    _objectTypes = new List<SceneObjectType>();
    
    _camera = new Camera();
    
    _width = 0;
    _height = 0;
  }
  
  int get width => _width;
  int get height => _height;
  
  Camera get camera => _camera;
  
  List<SceneObject> get objects => _objects;
  
  /**
   * loadFromString
   * TODO
   */
  Future loadFromString(String scene, WebGL.RenderingContext renderingContext) {
    var jsonScene = JSON.decode(scene);
    return loadFromJson(jsonScene, renderingContext);
  }
  
  /**
   * loadFromJson
   * TODO
   */
  Future loadFromJson(var scene, WebGL.RenderingContext renderingContext) {
    if (scene['version'] != '1.0') {
      throw new UnsupportedVersionException('Unsupported scene version');
    }
    
    ShaderManager.instance.initialize(renderingContext);
    
    _width = scene['width'];
    _height = scene['height'];
    
    _camera.x = scene['camera'][0];
    _camera.y = scene['camera'][1];
    
    _backgroundColor = scene['backgroundColor'];
    
    _tileSize = scene['tileSize'];
    _events = scene['eventMap'];
    
    _tileSets.clear();

    List<Future> futures = new List<Future>();
    
    for (var jsonTileSet in scene['tileSets']) {
      TileSet tileSet = new TileSet();
      Future future = tileSet.loadFromJson(jsonTileSet, renderingContext);
      _tileSets[tileSet.image] = tileSet;
      futures.add(future);
    }
    
    _layers.clear();
    
    for (var jsonLayer in scene['layers']) {
      Layer layer = new Layer(_width, _height);
      layer.loadFromJson(jsonLayer, _tileSets, renderingContext);
      layer.startCamera = _camera;
      _layers.add(layer);
    }
    
    _objectTypes.clear();
    
    for (var jsonObjectType in scene['objectTypes']) {
      SceneObjectType objectType = new SceneObjectType();
      objectType.loadFromJson(jsonObjectType, _tileSets, renderingContext);
      _objectTypes.add(objectType);
    }
    
    _objects.clear();
    
    for (var jsonObject in scene['objects']) {
      SceneObject object = new SceneObject.data(jsonObject['type'], jsonObject['x'], 
          jsonObject['y'], jsonObject['visible'], jsonObject['initialState'],
          jsonObject['drawsToAdvanceFrame']);
      _objects.add(object);
    }

    return Future.wait(futures);
  }
  
  int event(int x, int y) {
    int indexX = x ~/ _tileSize;
    int indexY = y ~/ _tileSize;
    if (indexX >= 0 && indexY >= 0 && indexY < _events.length && indexX <_events[0].length) {
      return _events[indexY][indexX];
    } else {
      return 0;
    }
  }
  
  void changeEvent(int x, int y, int event) {
    int indexX = x ~/ _tileSize;
    int indexY = y ~/ _tileSize;
    if (indexX >= 0 && indexY >= 0 && indexY < _events.length && indexX <_events[0].length) {
      _events[indexY][indexX] = event;
    }
  }
  
  /**
   * draw
   * TODO
   */
  void draw(WebGL.RenderingContext renderingContext) {
    
    if (_layers.isEmpty) {
      throw new NoLayersFoundException('No layers found');
    }
    
    // Set viewport size
    renderingContext.viewport(0, 0, _width, _height);

    // Clear color buffer
    renderingContext.clearColor(_backgroundColor[0], _backgroundColor[1], _backgroundColor[2], 1.0);
    renderingContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT);

    // Create Orthogonal matrix
    Float32List cameraTransform = _buildCameraMatrix();
    
    for (var layer in _layers) {
      layer.draw(renderingContext, cameraTransform, _camera, _objectTypes, _objects);
    }
  }
  
  Float32List _buildCameraMatrix() {
    
    /**
     * glOrtho(left, right, bottom, top, near, far);
     * 
     * [2 / (right - left)            0                   0       tx]
     * [        0           2 / (bottom - top)            0       ty]
     * [        0                     0         -2 / (far - near) tz]
     * [        0                     0                   0        1]
     * 
     * tx = -(right + left)/(right - left)
     * ty = -(bottom + top)/(bottom - top)
     * tz = -(far + near)/(far - near)
     */
   
    Float32List cameraTransform = new Float32List(16);
    
    double bottom = _camera.y - _height / 2; // it's upsidedown respect the
                                             // classic OpenGL axis
    double left = _camera.x - _width / 2;
    
    double top = bottom + _height;
    
    double right = left + _width;
    
    cameraTransform[0] = 2 / (right - left);
    cameraTransform[1] = 0.0;
    cameraTransform[2] = 0.0;
    cameraTransform[3] = 0.0;
    
    cameraTransform[4] = 0.0;
    cameraTransform[5] = 2 / (bottom - top);
    cameraTransform[6] = 0.0;
    cameraTransform[7] = 0.0;
    
    cameraTransform[8] = 0.0;
    cameraTransform[9] = 0.0;
    cameraTransform[10] = -1.0; // -2 / (1 - (-1)) 
    cameraTransform[11] = 0.0;
    
    cameraTransform[12] = -(right + left)/(right - left);
    cameraTransform[13] = -(bottom + top)/(bottom - top);
    cameraTransform[14] = 0.0; // tz = -((1 + (-1))/(1 - (-1)))
    cameraTransform[15] = 1.0;
    
    return cameraTransform;
  }
  
}
