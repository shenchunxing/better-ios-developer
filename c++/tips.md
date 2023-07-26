### c++的struct和c的区别？
```
C中声明结构体
  变量需要加上struct关键字
  C++不需要
C中的结构体
  只能定义成员变量
  不能定义成员函数。
C++既
  可以定义成员变量
  也可以定义成员函数
//1. 结构体中即可以定义成员变量，也可以定义成员函数
 struct Student{
     string mName;
     int mAge;
     void setName(string name){ mName = name; }
     void setAge(int age){ mAge = age; }
     void showStudent(){
            cout << "Name:" << mName << " Age:" << mAge << endl;
     }
 };
 //2. c++中定义结构体变量不需要加struct关键字
 void test01(){
     Student student;
     student.setName("John");
     student.setAge(20);
     student.showStudent();
 }

```

### C++的结构体和类的区别?
成员访问权限：

结构体（struct）：默认情况下，结构体中的成员都是公共的（public），这意味着在结构体外部可以直接访问结构体的成员。
类（class）：默认情况下，类中的成员是私有的（private），这意味着在类外部不能直接访问类的私有成员。可以通过公共成员函数（public member functions）来访问和操作私有成员。
继承：

结构体（struct）：在 C++ 中，结构体也可以使用继承，但默认继承访问权限是公共继承（public inheritance），即派生类继承的成员在外部具有相同的访问权限。
类（class）：类可以使用公共继承、私有继承和受保护继承等多种继承方式，可以更灵活地控制成员的访问权限。
默认访问权限：

结构体（struct）：默认访问权限是公共的（public）。
类（class）：默认访问权限是私有的（private）。
成员函数：

结构体（struct）：可以有成员函数，但不能定义构造函数和析构函数。
类（class）：可以有成员函数，可以定义构造函数和析构函数，构造函数用于初始化对象，析构函数用于释放对象所占用的资源。
类型的使用：

结构体（struct）：通常用于数据的封装，表示一组相关的数据项。
类（class）：除了数据的封装外，还可以实现更复杂的行为，包括数据封装、函数封装和继承等特性。

### const
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/517050b4a4984117a63066e8d22a8964~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
