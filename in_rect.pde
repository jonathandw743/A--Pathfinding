boolean in_rect(PVector pos, PVector rpos, float w, float h) {
  float l = rpos.x;
  float t = rpos.y;
  float r = l + w;
  float b = t + h;
  if(pos.x >= l && pos.y >= t && pos.x <= r && pos.y <= b) {
    return true;
  } else {
    return false;
  }
}
