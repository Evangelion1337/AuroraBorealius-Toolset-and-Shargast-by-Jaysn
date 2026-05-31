use rodio::Source;
use std::collections::HashMap;
use std::sync::Mutex;

pub struct AudioSystem {
    handle: Option<rodio::OutputStreamHandle>,
    _stream: Option<rodio::OutputStream>,
    active_sounds: Mutex<HashMap<String, rodio::Sink>>,
}

impl AudioSystem {
    pub fn new() -> Self {
        if let Ok((stream, handle)) = rodio::OutputStream::try_default() {
            Self {
                handle: Some(handle),
                _stream: Some(stream),
                active_sounds: Mutex::new(HashMap::new()),
            }
        } else {
            eprintln!("WARN: No audio output device available");
            Self {
                handle: None,
                _stream: None,
                active_sounds: Mutex::new(HashMap::new()),
            }
        }
    }

    pub fn play_wav(&self, id: &str, data: &[u8], loop_: bool) {
        let Some(ref handle) = self.handle else { eprintln!("play_wav: no handle (no audio device)"); return; };
        let cursor = std::io::Cursor::new(data.to_vec());
        match rodio::Decoder::new(cursor) {
            Ok(source) => {
                let sink = rodio::Sink::try_new(handle).ok();
                if let Some(sink) = sink {
                    if loop_ {
                        sink.append(source.repeat_infinite());
                    } else {
                        sink.append(source);
                    }
                    sink.play();
                    if let Ok(mut active) = self.active_sounds.lock() {
                        active.insert(id.to_string(), sink);
                        eprintln!("play_wav: '{}' playing ({} sinks active)", id, active.len());
                    }
                } else {
                    eprintln!("play_wav: '{}' sink creation failed", id);
                }
            }
            Err(e) => {
                eprintln!("WARN: Failed to decode audio '{}': {:?}", id, e);
            }
        }
    }

    pub fn stop(&self, id: &str) {
        if let Ok(mut active) = self.active_sounds.lock() {
            if let Some(sink) = active.remove(id) {
                sink.stop();
            }
        }
    }

    pub fn stop_all(&self) {
        if let Ok(mut active) = self.active_sounds.lock() {
            for (_, sink) in active.drain() {
                sink.stop();
            }
        }
    }

    pub fn cleanup_finished(&self) {
        if let Ok(mut active) = self.active_sounds.lock() {
            active.retain(|_, sink| !sink.empty());
        }
    }
}
