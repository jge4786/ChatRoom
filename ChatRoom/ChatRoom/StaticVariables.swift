import UIKit

struct Constants {
    static let users: [User] = [
        User("하나"),
        User("둘"),
//        User("셋"),
//        User("넷"),
//        User("다섯"),
//        User("여섯"),
//        User("777777"),
//        User("888888"),
//        User("999999"),
//        User("여000000섯"),
//        User("여1010101010섯"),
//        User("여1111111섯"),
//        User("여12121212121섯"),
//        User("131313133여섯"),
//        User("141441414여섯"),
//        User("15415115151여섯"),
//        User("161616161616여섯"),
//        User("17771717171여섯"),
//        User("18881181818여섯"),
//        User("1919191919199여섯"),
//        User("202020202020여섯"),
//        User("여21121212섯"),
//        User("2222222여섯"),
//        User("232323232323232여섯"),
//        User("204242424242여섯"),
//        User("25252552여섯"),
//        User("26266262626262여섯"),
//        User("여섯27277277272"),
//        User("여섯28282828282"),
//        User("여섯92929292929292"),
//        User("여섯3030303030"),
//        User("여섯31313131331"),
//        User("여섯323323232323"),
//        User("333333333"),
//        User("34343334"),
//        User("35353535353"),
//        User("36366363636"),
//        User("37373737373"),
//        User("38383838383"),
//        User("3939393939393"),
//        User("4040040404040"),
//        User("4141141414141"),
//        User("42424242424"),
//        User("43343434343434"),
//        User("44444444"),
//        User("454545454545"),
//        User("464646464646"),
//        User("7474747474747"),
//        User("488484848484848"),
//        User("4949494949494949"),
//        User("50505050505050"),
//        User("5151515151515"),
//        User("5252525252525225"),
//        User("5335353535353535"),
//        User("54545454545445"),
    ]
}

struct Color {
    //내가 보낸 채팅
    static var Yellow: CGColor { return CGColor(red: 254/255, green: 240/255, blue: 27/255, alpha: 1.0) }
    //상대방이 보낸 채팅
    static var White: CGColor { return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) }
    //읽지 않은 사용자의 수
    static var DarkYellow: CGColor { return CGColor(red: 254/255, green: 234/255, blue: 51/255, alpha: 1.0)}
    //날짜 라벨 배경색
    static var DarkGray: CGColor { return CGColor(red: 156/255, green: 175/255, blue: 191/255, alpha: 1.0)}
    //카카오톡 기본 배경색
    static var LightBlue: CGColor { return CGColor(red: 155/255, green: 187/255, blue: 212/255, alpha: 1.0)}
    //카카오톡 검정색 테마의 입력창 배경색
    static var LightBlack: CGColor { return CGColor(red: 46/255, green: 44/255, blue: 48/255, alpha: 1.0)}
    //카카오톡 검정색 테마의 배경색
    static var Black: CGColor { return CGColor(red: 40/255, green: 38/255, blue: 42/255, alpha: 1.0)}
    //카카오톡 검정색 테마의 입력창 배경색
    static var LighterBlack: CGColor { return CGColor(red:58/255, green: 56/255, blue: 61/255, alpha: 1.0)}
}
