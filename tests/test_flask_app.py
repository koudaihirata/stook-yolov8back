import pytest
from app import app, detected_objects
from unittest import mock

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_index(client):
    response = client.get('/')
    assert response.status_code == 200

@mock.patch('app.model')  # YOLOモデルをモック化
def test_detect_upload(mock_model, client):
    mock_result = mock.Mock()
    mock_result.plot.return_value = None
    mock_result.boxes.cls = [0]  # 仮のクラスID
    mock_model.return_value = [mock_result]

    data = {
        'image': 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBD...'
    }
    response = client.post('/upload', json=data)
    assert response.status_code == 200
    assert detected_objects == ['person']  # モックのクラスIDが0（例: 'person'）

def test_get_results(client):
    response = client.get('/results')
    assert response.status_code == 200
    assert isinstance(response.json, list)
