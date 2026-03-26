#!/usr/bin/env python3
"""
LineageRPG 자동 개발 시스템 - 오토파일럿
30분마다 실행되어 에이전트 상태 체크 및 태스크 할당
"""

import json
import subprocess
import os
from datetime import datetime
from pathlib import Path

PROJECT_DIR = Path(__file__).parent.parent
STATE_FILE = PROJECT_DIR / ".agents" / "state.json"
REPO_DIR = PROJECT_DIR

def load_state():
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            return json.load(f)
    return {"agents": {}, "last_check": None}

def save_state(state):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    state["last_check"] = datetime.now().isoformat()
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

def get_open_issues():
    """GitHub에서 P0 이슈 가져오기"""
    result = subprocess.run(
        ["gh", "issue", "list", "--state", "open", "--label", "P0", "--json", "number,title,body"],
        cwd=REPO_DIR,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"이슈 조회 실패: {result.stderr}")
        return []
    return json.loads(result.stdout)

def get_idle_agent(state):
    """idle 상태인 에이전트 찾기"""
    for name, agent in state.get("agents", {}).items():
        if agent.get("status") == "idle":
            return name
    return None

def assign_issue_to_agent(state, agent_name, issue):
    """에이전트에 이슈 할당"""
    if agent_name not in state["agents"]:
        state["agents"][agent_name] = {}
    
    state["agents"][agent_name].update({
        "status": "working",
        "current_issue": issue["number"],
        "last_activity": datetime.now().isoformat()
    })
    return True

def report_to_discord(message):
    """Discord #lineage-rpg 채널로 보고"""
    # OpenClaw sessions_send 사용
    subprocess.run([
        "openclaw", "send",
        "--channel", "discord",
        "--to", "1486755905549762710",
        message
    ], capture_output=True)

def main():
    print(f"[{datetime.now()}] LineageRPG 오토파일럿 시작")
    
    state = load_state()
    
    # 1. 열린 P0 이슈 확인
    issues = get_open_issues()
    print(f"열린 P0 이슈: {len(issues)}개")
    
    if not issues:
        print("할 일 없음 - 대기")
        report_to_discord("🎮 LineageRPG: 할 일 없음. 새 이슈 대기 중...")
        save_state(state)
        return
    
    # 2. idle 에이전트 찾기
    idle_agent = get_idle_agent(state)
    
    if not idle_agent:
        print("모든 에이전트 작업 중")
        save_state(state)
        return
    
    # 3. 이슈 할당
    next_issue = issues[0]
    assign_issue_to_agent(state, idle_agent, next_issue)
    
    print(f"{idle_agent} 에이전트에 이슈 #{next_issue['number']} 할당")
    report_to_discord(
        f"🚀 **{idle_agent.upper()}** 에이전트 시작\n"
        f"📋 이슈 #{next_issue['number']}: {next_issue['title']}\n"
        f"🔗 https://github.com/elfguy/lineage-rpg/issues/{next_issue['number']}"
    )
    
    save_state(state)
    print("완료")

if __name__ == "__main__":
    main()
