import 'package:flutter/material.dart';

class UserState {
  // 현재 로그인한 사용자 ID
  static const String myId = 'ta_junhyuk';
  
  // [데이터] 내 프로필 사진 URL
  static String _myAvatarUrl = 'assets/images/profile3.jpg';
  
  // 내 프로필 사진 가져오기
  static String getMyAvatarUrl() => _myAvatarUrl;
  
  // 내 프로필 사진 업데이트
  static void updateMyAvatarUrl(String newUrl) {
    _myAvatarUrl = newUrl;
  }

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
      {'username': 'aerichandesu', 'name': 'GISELLE', 'img': 'aerichandesu'},
      {'username': 'imnotningning', 'name': 'NINGNING', 'img': 'imnotningning'},
      {'username': 'katarinabluu', 'name': 'KARINA', 'img': 'katarinabluu'},
      {'username': 'aespa_official', 'name': 'aespa 에스파', 'img': 'aespa_official'},
    ],
  };

  // 간단한 인증(verified) 시뮬레이션
  static final Set<String> _verified = {
    'imwinter', 'imnotningning', 'katarinabluu', 'aespa_official', 'aerichandesu'
  };

  static bool isVerified(String username) => _verified.contains(username);

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