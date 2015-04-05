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
part 'common_object.dart';
part 'scene_object.dart';
part 'scene_object_type.dart';
part 'text_object.dart';

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
    if (_currentScene != null) {
      _currentScene.cleanUp(_renderingContext);
    }
    
    _currentScene = new Scene();
    
    Future future = _currentScene.loadFromJson(scene, _renderingContext);

    _currentScene.viewportWidth = _canvas.width;
    _currentScene.viewportHeight = _canvas.height;
    
    return future;
  }
  
  void cleanUp() {
    if (_currentScene != null) {
      _currentScene.cleanUp(_renderingContext);
    }
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
  
  SceneObject getObject(int objectId) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    return _currentScene.sceneObjects[objectId];
  }
  
  int get cameraX => _currentScene.camera.x;
  int get cameraY => _currentScene.camera.y;
  
  
  /**
   * Camera management functions
   */
  
  void set cameraX(int x) {
    _currentScene.camera.x = x;
  }
  
  void set cameraY(int y) {
    _currentScene.camera.y = y;
  }

  
  /**
   * Events functions
   */
  
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
    
    _currentScene.changeEvent(x, y, value);
  }

  
  /**
   * Scene objects management functions
   */
  
  int addObject(SceneObject object, int layer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    return _currentScene.addSceneObject(object, layer);
  }
  
  void removeObject(int index, int layer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.removeSceneObject(index, layer);
  }
  
  void changeObject(int index, SceneObject newObject) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.changeSceneObject(index, newObject);
  }
  
  void changeObjectBetweenLayers(int index, int fromLayer, int toLayer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.changeSceneObjectBetweenLayers(index, fromLayer, toLayer);
  }
  
  
  /**
   * Text functions
   */
  
  int addText(String text, int x, int y, String tileSet, int layer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    return _currentScene.addText(text, x, y, tileSet, layer, _renderingContext);
  }
  
  void removeText(int index, int layer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.removeTextObject(index, layer, _renderingContext);
  }
  
  void changeText(int index, String text) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    TextObject textObject = _currentScene.textObjects[index];
    textObject.text = text;
    textObject.updateBuffers(_renderingContext);
  }
  
  void changeTextX(int index, int x) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }

    _currentScene.textObjects[index].x = x;
  }
  
  void changeTextY(int index, int y) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }

     _currentScene.textObjects[index].y = y;
  }
  
  void changeTextPosition(int index, int x, int y) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }

    TextObject textObject = _currentScene.textObjects[index];
    textObject.x = x;
    textObject.y = y;
  }
  
  void changeTextVisibility(int index, bool visible) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.textObjects[index].visible = visible;
  }
  
  void changeTextBetweenLayers(int index, int fromLayer, int toLayer) {
    if (_currentScene == null) {
      throw new NoSceneFoundException('No current scene available');
    }
    
    _currentScene.changeTextObjectBetweenLayers(index, fromLayer, toLayer);
  }
  
  WebGL.RenderingContext get renderingContext => _renderingContext;
}
