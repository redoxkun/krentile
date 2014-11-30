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

class SceneObject {
  
  int _type;
  
  int _x;
  int _y;
  
  bool _visible;
  
  int _state;
  
  int _frame;
  
  bool _autoAnimation;
  
  int _drawsToAdvanceFrame;
  int _drawsAdvanced;
  
  SceneObject.data(this._type, this._x, this._y,
      this._visible, this._state, this._drawsToAdvanceFrame) {
    _frame = 0;
    _autoAnimation = true;
    _drawsAdvanced = 0;
  }
  
  int get type => _type;
  void set type(int type) {
    _type = type;
  }
  
  int get x => _x;
  void set x(int x) {
    _x = x;
  }
  
  int get y => _y;
  void set y(int y) {
    _y = y;
  }
  
  bool get visible => _visible;
  void set visible(bool visible) {
    _visible = visible;
  }
  
  int get state => _state;
  void set state(int state) {
    if (state != _state) {
      _frame = 0;
      _drawsAdvanced = 0;
      _state = state;
    }
  }
  
  int get frame => _frame;
  void set frame(int frame) {
    _frame = frame;
    _drawsAdvanced = 0;
  }
  
  bool get autoAnimation => _autoAnimation;
  void set autoAnimation(bool autoAnimation) {
    _autoAnimation = autoAnimation;
  }
  
  int get drawsToAdvanceFrame => _drawsToAdvanceFrame;
  void set drawsToAdvanceFrame(int drawsToAdvanceFrame) {
    _drawsToAdvanceFrame = drawsToAdvanceFrame;
  }
  
  int get drawsAdvanced => _drawsAdvanced;
  void set drawsAdvanced(int drawsAdvanced) {
    _drawsAdvanced = drawsAdvanced;
  }
  
  bool get advanceFrame => ((_drawsAdvanced + 1) >= _drawsToAdvanceFrame);
  void advanceDraw() {
    _drawsAdvanced++;
  }
  
}
