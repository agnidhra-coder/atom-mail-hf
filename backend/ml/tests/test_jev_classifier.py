import os
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import jev_classifier

class FakeResp:
    def __init__(self, status_code, json_data, text=""):
        self.status_code = status_code
        self._json = json_data
        self.text = text
    def json(self):
        return self._json

def test_urgent_work(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        return FakeResp(200, {"answers": {"category": {"value": 0}, "urgency": {"noul": 0.92}}})
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("URGENT: server breached 96%")
    assert r["category"] == "Work"
    assert r["is_urgent"] is True

def test_non_urgent_personal(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        return FakeResp(200, {"answers": {"category": {"value": 1}, "urgency": {"noul": 0.1}}})
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("hey how are you")
    assert r["category"] == "Personal"
    assert r["is_urgent"] is False

def test_noul_threshold_edge(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        return FakeResp(200, {"answers": {"category": {"value": 3}, "urgency": {"noul": 0.75}}})
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("edge")
    assert r["is_urgent"] is True

def test_fallback_no_key(monkeypatch):
    monkeypatch.delenv("OPENCODE_API_KEY", raising=False)
    jev_classifier.ZEN_API_KEY = None
    r = jev_classifier.triage_email_with_jev("anything")
    assert r == {"category": "Updates", "is_urgent": False}

def test_fallback_server_error(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        return FakeResp(500, {}, "Internal Server Error")
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("body")
    assert r == {"category": "Updates", "is_urgent": False}

def test_fallback_exception(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        raise RuntimeError("network down")
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("body")
    assert r == {"category": "Updates", "is_urgent": False}

def test_out_of_range_index(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    def fake_post(*a, **kw):
        return FakeResp(200, {"answers": {"category": {"value": 99}, "urgency": {"noul": 0.0}}})
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    r = jev_classifier.triage_email_with_jev("body")
    assert r["category"] == "Updates"

def test_batch_parallel(monkeypatch):
    monkeypatch.setenv("OPENCODE_API_KEY", "test-key")
    jev_classifier.ZEN_API_KEY = "test-key"
    calls = []
    def fake_post(*a, **kw):
        calls.append(kw.get("json", {}).get("state"))
        return FakeResp(200, {"answers": {"category": {"value": 2}, "urgency": {"noul": 0.8}}})
    monkeypatch.setattr(jev_classifier.requests, "post", fake_post)
    results = jev_classifier.triage_batch(["a", "b", "c"])
    assert len(results) == 3
    assert all(r["category"] == "Finance" and r["is_urgent"] for r in results)
