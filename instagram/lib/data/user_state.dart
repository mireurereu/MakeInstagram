import 'package:flutter/material.dart';

class UserState {
  // 현재 로그인한 사용자 ID
  static const String myId = 'ta_junhyuk';

  // [데이터] 내가 팔로우한 사람 목록 (Set으로 중복 방지)
  static final Set<String> _myFollowingList = {
    'imwinter', 
    'katarinabluu', 
    'aespa_official',
    'junehxuk',
    'yonghyeon5670',
    'cch991112',
    'haetbaaan',
    'cau_ai_',
    'chunganguniv'
  };

  // [데이터] 다른 사용자의 팔로잉 목록 (시나리오용 하드코딩)
  static final Map<String, List<Map<String, String>>> _otherUsersFollowing = {
    'imwinter': [
      {'username': 'katarinabluu', 'name': 'KARINA', 'img': 'karina'},
      {'username': 'ningning', 'name': 'NINGNING', 'img': 'ningning'}, // 더미
      {'username': 'giselle', 'name': 'GISELLE', 'img': 'giselle'}, // 더미
      {'username': 'new_user_1', 'name': 'New User', 'img': 'post1'}, // 팔로우 테스트용
    ],
  };

  // 내가 팔로우 중인지 확인
  static bool amIFollowing(String targetUsername) {
    return _myFollowingList.contains(targetUsername);
  }

  // 팔로우 토글 기능
  static void toggleFollow(String targetUsername) {
    if (_myFollowingList.contains(targetUsername)) {
      _myFollowingList.remove(targetUsername);
    } else {
      _myFollowingList.add(targetUsername);
    }
  }

  // 팔로잉 숫자 가져오기
  static int getFollowingCount(String username) {
    if (username == myId) {
      return _myFollowingList.length;
    }
    return _otherUsersFollowing[username]?.length ?? 0;
  }

  // 팔로잉 리스트 데이터 가져오기
  static List<Map<String, String>> getFollowingList(String username) {
    if (username == myId) {
      // 내 목록은 간단히 변환해서 반환 (실제론 더 복잡하겠지만 시나리오용)
      return _myFollowingList.map((id) => {'username': id, 'name': id, 'img': 'default'}).toList();
    }
    return _otherUsersFollowing[username] ?? [];
  }
}