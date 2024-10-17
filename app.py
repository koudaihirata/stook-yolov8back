from flask import Flask, Response, render_template, request, jsonify
from flask_cors import CORS
import cv2
from ultralytics import YOLO
import base64
from io import BytesIO
from PIL import Image
import numpy as np

app = Flask(__name__)
CORS(app)

model = YOLO('models/yolov8n.pt')
detected_objects = []

def generate_frames():
    global detected_objects
    cap = cv2.VideoCapture(0)  # 0は内蔵カメラを指します

    if not cap.isOpened():
        print("Failed to open camera")
        return

    while True:
        success, frame = cap.read()
        if not success:
            print("Failed to capture image")
            break

        # YOLOv8モデルで推論を実行
        results = model(frame)
        print("Inference done")

        # 結果をフレームに描画
        annotated_frame = frame.copy()
        if results and results[0]:
            annotated_frame = results[0].plot()
            detected_objects = [model.names[int(x)] for x in results[0].boxes.cls]

        # フレームをJPEGにエンコード
        ret, buffer = cv2.imencode('.jpg', annotated_frame)
        if not ret:
            print("Failed to encode image")
            break

        frame = buffer.tobytes()
        print("Frame encoded successfully")

        # フレームをレスポンスとして返す
        yield (b'--frame\r\n'
            b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')

    cap.release()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/detect', methods=['GET'])
def detect():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/upload', methods=['POST'])
def upload():
    data = request.get_json()
    if 'image' not in data:
        return jsonify({'status': 'error', 'message': 'No image data provided.'}), 400

    image_data = data['image']
    image_data = image_data.split(',')[1]
    image_data = base64.b64decode(image_data)
    image = Image.open(BytesIO(image_data))

    # 画像をOpenCV形式に変換
    image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

    # YOLOv8での処理を実行
    results = model(image)
    annotated_frame = image.copy()
    if results and results[0]:
        annotated_frame = results[0].plot()
        detected_objects = [model.names[int(x)] for x in results[0].boxes.cls]

    # 処理結果を返す
    return jsonify(detected_objects)

@app.route('/results', methods=['GET'])
def get_results():
    global detected_objects
    return jsonify(detected_objects)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
