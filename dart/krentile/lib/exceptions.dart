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

/**
 * WebGLUnsupportedException
 * 
 * This exception is thrown when WebGL
 * is not available.
 */
class WebGLUnsupportedException implements Exception {
  
  final String _msg;
  
  const WebGLUnsupportedException(this._msg);
  
  String get message => _msg;
  
}

/**
 * NoCurrentSceneException
 * 
 * This exception is thrown when an
 * scene is not available.
 */
class NoSceneFoundException implements Exception {
  
  final String _msg;
  
  const NoSceneFoundException(this._msg);
  
  String get message => _msg;
  
}

/**
 * NoLayersFoundException
 * 
 * This exception is thrown when there are
 * any layers available to render.
 */
class NoLayersFoundException implements Exception {
  
  final String _msg;
  
  const NoLayersFoundException(this._msg);
  
  String get message => _msg;
  
}

/**
 * UninitializedParameterException
 * 
 * This exception is thrown when an
 * uninitialized parameter is found.
 */
class UninitializedParameterException implements Exception {
  
  final String _msg;
  
  const UninitializedParameterException(this._msg);
  
  String get message => _msg;
  
}

/**
 * UnsupportedVersionException
 * 
 * This exception is thrown when a non supported
 * version is tried to load.
 */
class UnsupportedVersionException implements Exception {
  
  final String _msg;
  
  const UnsupportedVersionException(this._msg);
  
  String get message => _msg;
  
}
