import 'package:flutter/material.dart';

class UserState {
  // 현재 로그인한 사용자 ID
  static const String myId = 'kkuma';
  
  // [데이터] 내 프로필 사진 URL - ValueNotifier로 변경하여 실시간 업데이트
  static final ValueNotifier<String> _myAvatarUrlNotifier = ValueNotifier('assets/images/profiles/kkuma.jpg');
  
  // 프로필 사진 변경 여부 플래그
  static bool _hasChangedProfilePicture = false;
  
  // 내 프로필 사진 Notifier 가져오기 (리스닝용)
  static ValueNotifier<String> get myAvatarUrlNotifier => _myAvatarUrlNotifier;
  
  // 내 프로필 사진 가져오기
  static String getMyAvatarUrl() => _myAvatarUrlNotifier.value;
  
  // 내 프로필 사진 업데이트 - 모든 리스너에게 즉시 알림
  static void updateMyAvatarUrl(String newUrl) {
    _myAvatarUrlNotifier.value = newUrl;
  }

  // 프로필 사진 설정 (Edit Profile에서 사용)
  static void setMyAvatarUrl(String newUrl) {
    _myAvatarUrlNotifier.value = newUrl;
  }

  // 프로필 사진 변경 플래그 설정
  static void setProfilePictureChanged(bool value) {
    _hasChangedProfilePicture = value;
  }

  // 프로필 사진 변경 여부 확인
  static bool hasChangedProfilePicture() {
    return _hasChangedProfilePicture;
  }

  static bool hasStory(String username) => storyUsers.contains(username);

  // [데이터] 내가 팔로잉하는 사용자 ID 목록
  static final Set<String> _myFollowingList = {
    'hangyo', 
    'sanrio_official',
    'mymelody',
    'kuromi',
    'pochacco',
    'hellokitty', 
    'pompom',
    'keroppi',
    'cinnamo'
  };

  // [데이터] 다른 사용자의 팔로잉 목록 (시나리오용 하드코딩)
  static final Map<String, List<Map<String, String>>> _otherUsersFollowing = {
    'hellokitty': [
      {'username': 'npochamu', 'name': 'chamuu', 'img': 'npochamu'},
      {'username': 'imnotningning', 'name': 'NINGNING', 'img': 'imnotningning'},
      {'username': 'hangyo', 'name': 'blue', 'img': 'hangyo'},
      {'username': 'sanrio_official', 'name': 'we are one', 'img': 'sanrio_official'},
    ],
  };

  static const Set<String> storyUsers = {
    'keroppi', 
    'hangyo', 
    'sanrio_official', 
    'hellokitty', 
    'pompom'
  };

  // 간단한 인증(verified) 시뮬레이션
  static final Set<String> _verified = {
    'hellokitty', 'imnotningning', 'hangyo', 'sanrio_official', 'npochamu'
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