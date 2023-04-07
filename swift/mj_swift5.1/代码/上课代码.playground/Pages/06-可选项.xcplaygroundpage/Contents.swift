var age: Int? = 10
print(age)

print("my age is \(String(describing: age))")


if let number = Int("123") {
    print("\(number)")
}

enum Season : Int {
    case spring = 1 ,summer , aotomn , winter
}

if let season = Season(rawValue: 6) {
    
} else {
    print("error")
}

func login(_ info : [String : String]) {
    let username : String
    if let temp = info["username"] {
        username = temp
    } else {
        print("username 不能为空")
        return
    }
    
    let password : String
    if let temp = info["username"] {
        password = temp
    } else {
        print("password 不能为空")
        return
    }
    
    print("username = \(username) , password = \(password)")
}

func login2(_ info : [String : String]) {
    guard let username = info["username"] , let password = info["password"] else {
        return
    }
    print("username = \(username) , password = \(password)")
}


var age1 : Int? = 10
print(String(age1 ?? 0))
print(String(describing: age1))
print("my age is \(age1 ?? 0)")
