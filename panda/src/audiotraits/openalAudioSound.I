/**
 * PANDA 3D SOFTWARE
 * Copyright (c) Carnegie Mellon University.  All rights reserved.
 *
 * All use of this software is subject to the terms of the revised BSD
 * license.  You should have received a copy of this license along
 * with this source code in a file named "LICENSE."
 *
 * @file openalAudioSound.I
 * @author Ben Buchwald <bb2@alumni.cmu.edu>
 */

/**
 * Sets the sound's calibrated clock.
 *
 * OpenAL is not very accurate at reporting how much time has elapsed within a
 * buffer.  However, it does accurately report when it has finished playing a
 * buffer.  So we use a hybrid clock algorithm.  When OpenAL is in the middle
 * of a buffer, we use a real-time-clock to estimate how far the sound has
 * gotten.  Each time OpenAL reaches the end of a buffer (which it does every
 * 1/4 second or so), we calibrate our real-time-clock by speeding it up or
 * slowing it down.
 */
INLINE void OpenALAudioSound::
set_calibrated_clock(double rtc, double t, double accel) {
  _calibrated_clock_scale = _playing_rate * accel;
  _calibrated_clock_base = rtc - (t / _calibrated_clock_scale);
}

/**
 * Returns the value of the calibrated clock.
 */
INLINE double OpenALAudioSound::
get_calibrated_clock(double rtc) const {
  return (rtc - _calibrated_clock_base) * _calibrated_clock_scale;
}

/**
 * Makes sure the sound data record is present, and if not, obtains it.
 *
 * Returns true on success, false on failure.
 */
bool OpenALAudioSound::
require_sound_data() {
  if (_sd==0) {
    _sd = _manager->get_sound_data(_movie, _desired_mode);
    if (_sd==0) {
      audio_error("Could not open audio " << _movie->get_filename());
      return false;
    }
  }
  return true;
}

/**
 * Checks if the sound data record is present and releasable, and if so,
 * releases it.
 */
void OpenALAudioSound::
release_sound_data() {
  if ((_sd!=0) && (!_movie->get_filename().empty())) {
    _manager->decrement_client_count(_sd);
    _sd = 0;
  }
}
