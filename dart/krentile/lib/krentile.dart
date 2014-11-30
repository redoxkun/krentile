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

library krentile;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';
import 'dart:web_gl' as WebGL;
import 'dart:typed_data';

part 'scene.dart';
part 'layer.dart';
part 'tileset.dart';
part 'tile.dart';
part 'camera.dart';
part 'scene_object.dart';
part 'scene_object_type.dart';

part 'texture_manager.dart';
part 'shader_manager.dart';

part 'exceptions.dart';

class Krentile {
  
  final CanvasElement _canvas;
  final String _baseUrl;
  
  WebGL.RenderingContext _renderingContext;
  
  Scene _currentScene;
  
  Krentile(this._canvas, this._baseUrl) {
    _init();
  }
  
  void _init() {
    _renderingContext = _canvas.getContext3d(antialias: false);

    if (_renderingContext == null) {
      throw new WebGLUnsupportedException('WebGL not supported');
    }
    
    TextureManager.instance.baseUrl = _baseUrl;
  }
  
  /**
   * loadSceneString
   * TODO
   */
  Future loadSceneFromString(String scene) {
    var jsonScene = JSON.decode(scene);
    return loadSceneFromJson(jsonScene);
  }
  
  /**
   * loadSceneJson
   * TODO
   */
  Future loadSceneFromJson(var scene) {
    _currentScene = new Scene();
    
    Future future = _currentScene.loadFromJson(scene, _renderingContext);

    _canvas.width = _currentScene.width;
    _canvas.height = _currentScene.height;
    
    return future;
  }
  
  /**
   * draw
   * TODO
   */
  void draw() {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.draw(_renderingContext);
  }
  
  /**
   * finish
   * 
   * Clears any texture set
   */
  void disposeTextures() {
    TextureManager.instance.clearTextures();
  }
  
  SceneObject getObject(int objectId) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    return _currentScene.objects[objectId];
  }
  
  int get cameraX => _currentScene.camera.x;
  int get cameraY => _currentScene.camera.y;
  
  void set cameraX(int x) {
    _currentScene.camera.x = x;
  }
  
  void set cameraY(int y) {
    _currentScene.camera.y = y;
  }

  int event(int x, int y) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    return _currentScene.event(x, y);
  }
  
  void changeEvent(int x, int y, int value) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
  }
  
  WebGL.RenderingContext get renderingContext => _renderingContext;
}
