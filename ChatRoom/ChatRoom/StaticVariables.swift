import UIKit

struct Constants {
    static var deviceSize = CGSize(width: 0, height: 0)
    static var chatHeightLimit = 30
}

struct Color {
    ///내가 보낸 채팅
    static var Yellow: CGColor { return CGColor(red: 254/255, green: 240/255, blue: 27/255, alpha: 1.0) }
    ///상대방이 보낸 채팅
    static var White: CGColor { return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) }
    ///읽지 않은 사용자의 수
    static var DarkYellow: CGColor { return CGColor(red: 254/255, green: 234/255, blue: 51/255, alpha: 1.0)}
    ///날짜 라벨 배경색, 이름 텍스트 색
    static var DarkGray: CGColor { return CGColor(red: 156/255, green: 175/255, blue: 191/255, alpha: 1.0)}
    ///카카오톡 기본 배경색
    static var LightBlue: CGColor { return CGColor(red: 155/255, green: 187/255, blue: 212/255, alpha: 1.0)}
    ///카카오톡 검정색 테마의 입력창 배경색
    static var LightBlack: CGColor { return CGColor(red: 46/255, green: 44/255, blue: 48/255, alpha: 1.0)}
    ///카카오톡 검정색 테마의 배경색
    static var Black: CGColor { return CGColor(red: 40/255, green: 38/255, blue: 42/255, alpha: 1.0)}
    ///카카오톡 검정색 테마의 입력창 배경색
    static var LighterBlack: CGColor { return CGColor(red:58/255, green: 56/255, blue: 61/255, alpha: 1.0)}
    ///카카오톡 검정색 테마의 입력창 외곽선 색
    static var DarkerGray: CGColor { return CGColor(red: 70/255, green: 67/255, blue: 71/255, alpha: 1.0)}
}
