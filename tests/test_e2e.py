import requests

def test_index_e2e():
    response = requests.get('http://localhost:5001/')
    assert response.status_code == 200

def test_detect_results_e2e():
    # 事前にフレーム生成が成功することを確認する
    response = requests.get('http://localhost:5001/results')
    assert response.status_code == 200
    assert isinstance(response.json(), list)
