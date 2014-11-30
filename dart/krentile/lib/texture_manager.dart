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

class TextureManager {
  
  String _baseUrl;
  
  Map<String, WebGL.Texture> _textures;
  
  static TextureManager _instance;
  
  static TextureManager get instance {
    if (_instance == null) {
      _instance = new TextureManager._internal();
    }
    return _instance;
  }
  
  TextureManager._internal() {
    _textures = new Map<String, WebGL.Texture>();
  }
  
  void set baseUrl(String url) {
    _baseUrl = url;
  }
  
  Future load(String name, WebGL.RenderingContext renderingContext) {
    if (_baseUrl == null) {
      throw new UninitializedParameterException('Base url not initialized');
    }
    
    WebGL.Texture texture;
    
    if (_textures.containsKey(name)) {
      texture = _textures[name];
    } else {
      // Texture not found, create it...
      texture = renderingContext.createTexture();
      _textures[name] = texture;
    }
    
    ImageElement img = new ImageElement();
    Completer comp = new Completer();
    img.onLoad.listen((_) {
      renderingContext.bindTexture(WebGL.RenderingContext.TEXTURE_2D, texture);
      renderingContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D,
                       WebGL.RenderingContext.TEXTURE_MIN_FILTER,
                       WebGL.RenderingContext.NEAREST);
      renderingContext.texParameteri(WebGL.RenderingContext.TEXTURE_2D,
                       WebGL.RenderingContext.TEXTURE_MAG_FILTER,
                       WebGL.RenderingContext.NEAREST);
      renderingContext.texImage2D(WebGL.RenderingContext.TEXTURE_2D,
                    0,
                    WebGL.RenderingContext.RGBA,
                    WebGL.RenderingContext.RGBA,
                    WebGL.RenderingContext.UNSIGNED_BYTE,
                    img);
      comp.complete(img.src);
    });
    
    img.src = '$_baseUrl$name';
    
    return comp.future;
  }
  
  void bind(String name, WebGL.RenderingContext renderingContext) {
    WebGL.Texture texture = _textures[name];
    renderingContext.bindTexture(WebGL.RenderingContext.TEXTURE_2D, texture);
  }
  
  void clearTextures() {
    _textures = new Map<String, WebGL.Texture>();
  }
  
}
