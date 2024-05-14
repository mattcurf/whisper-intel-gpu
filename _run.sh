source /opt/intel/oneapi/setvars.sh
cd /workspace/whisper
python3 -m whisper --device xpu --language en --model medium tests/jfk.flac
