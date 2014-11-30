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

class ShaderManager {
  
  String _vertexShaderCode;
  String _fragmentShaderCode;
  
  WebGL.RenderingContext _renderingContext;
  
  WebGL.Shader _vertexShader;
  WebGL.Shader _fragmentShader;
  WebGL.Program _program;

  WebGL.UniformLocation _cameraTransform;
  WebGL.UniformLocation _positionOffset;
  int _positionAttributeIndex;
  int _textureAttributeIndex;
  
  static ShaderManager _instance;
  
  static ShaderManager get instance {
    if (_instance == null) {
      _instance = new ShaderManager._internal();
    }
    return _instance;
  }
  
  ShaderManager._internal() {
    _init();
  }
  
  void _init() {
    _vertexShaderCode = '''
      attribute vec2 vPosition;
      attribute vec2 vTexCoord;
      uniform mat4 cameraTransform;
      uniform vec2 positionOffset;

      varying vec2 samplePoint;

      void main(void)
      {
        vec2 vPosition2 = vPosition + positionOffset;
        vec4 vPosition4 = vec4(vPosition2.x,
                               vPosition2.y,
                               0.0,
                               1.0);
        gl_Position = cameraTransform * vPosition4;
        samplePoint = vTexCoord;
      }
    ''';
    
    _fragmentShaderCode = '''
      precision highp float;
      varying vec2 samplePoint;
      uniform sampler2D mapSampler;

      void main(void)
      {
        vec4 color = texture2D(mapSampler, samplePoint);
        if (color.a > 0.5) {
          gl_FragColor = vec4(color.xyz, 1.0);
        } else {
          discard;
        }
      }
    ''';
  }
  
  void initialize(WebGL.RenderingContext context) {
    _renderingContext = context;

    _vertexShader = _renderingContext.createShader(WebGL.RenderingContext.VERTEX_SHADER);
    _renderingContext.shaderSource(_vertexShader, _vertexShaderCode);
    _renderingContext.compileShader(_vertexShader);

    _fragmentShader = _renderingContext.createShader(WebGL.RenderingContext.FRAGMENT_SHADER);
    _renderingContext.shaderSource(_fragmentShader, _fragmentShaderCode);
    _renderingContext.compileShader(_fragmentShader);

    _program = _renderingContext.createProgram();
    _renderingContext.attachShader(_program, _vertexShader);
    _renderingContext.attachShader(_program, _fragmentShader);
    _renderingContext.linkProgram(_program);

    _cameraTransform = _renderingContext.getUniformLocation(program, 'cameraTransform');
    _positionOffset = _renderingContext.getUniformLocation(program, 'positionOffset');
    _positionAttributeIndex = _renderingContext.getAttribLocation(_program, 'vPosition');
    _textureAttributeIndex = _renderingContext.getAttribLocation(_program, 'vTexCoord');
  }
  
  WebGL.Program get program => _program;
  
  WebGL.UniformLocation get cameraTransform => _cameraTransform;
  
  WebGL.UniformLocation get positionOffset => _positionOffset;
  
  int get positionAttributeIndex => _positionAttributeIndex;
  
  int get textureAttributeIndex => _textureAttributeIndex;
  
}
