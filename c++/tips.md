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

c和c++对于const的区别？

1.C 中const默认为外部连接，C++中const默认为内部连接.
  当C语言两个文件中都有const int a的时候，编译器会报重定义的错误。
  而在C++中，则不会，因为C++中的const默认是内部连接的。如果想让C++中的const具有外部连接，必须显示声明为: extern const int a = 10;

2.在C++中，一个const不必创建内存空间，而在C中，一个const总是需要一块内存空间

```
 在C中
 const int arrSize = 10; //arrSize必须赋初值，占用内存。否则报错
 int arr[arrSize];//创建数组的时候，因为arrSize占用着内存，编译器不知道arrSize的大小，也会报错

```

3.对于全局的const，c会存储到只读数据段，C++中全局const当声明extern或者对变量取地址时，编译器会分配存储地址，变量存储在只读数据段。
```
c：
const int constA = 10;  全局作用域，即使通过指针也无法修改。会报错
int main(){
    int* p =(int*)&constA;
    *p = 200;
}
```

4.C语言中局部const存储在堆栈区。因为是局部作用域，可以通过指针修改。C++对局部const，如果是基本数据类型，直接定义是不会分配内存空间的。只有在取地址符，才会分配内存。如果是自定义对象，肯定要直接分配内存的。
```
c++：
     const int constA = 10;//不分配内存
     int* p = (int*)&constA;//分配内存
     *p = 300;
     cout << "constA:"<< constA << endl;
     cout << "*p:" << *p << endl;


     const Person person; //会分配内存

```

### 引用
引用的本质在C++内部实现是一个指针常量.
```
Type& ref = val; // Type* const ref = &val;

```
编译器削弱了它的功能，引用就是弱化了的指针。一个引用占用一个指针的大小。
```
//发现是引用，转换为 int* const ref = &a;
 void testFunc(int& ref){
     ref= 100; // ref是引用，转换为*ref = 100
 }
 int main(){
     int a = 10;
     int& aRef = a; //自动转换为 int* const aRef = &a;这也能说明引用为什么必须初始化（必须指向已经存在的内存）
     aRef= 20; //内部发现aRef是引用，自动帮我们转换为: *aRef = 20;
     cout<< "a:" << a << endl;
     cout<< "aRef:" << aRef << endl;
     testFunc(a);
     return EXIT_SUCCESS;
 }

 数组引用
 int array[] = {1,2,3};
 int (&ref1)[3] = array; //两种写法
 int* const &ref2 = array;

```

### 内联函数

用inline修饰
编译器会将函数调用直接展开为函数体代码、可以减少函数调用的开销、会增大代码体积
内联函数与宏：可以减少函数调用的开销。对比宏，内联函数多了语法检测和函数特性
```
#define sum(x) (x + x)
inline int sum(int x) { return x + x; }
int a = 10; sum(a++);
```

### 类和对象
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/25cf24f65d834cf79062c580ba782981~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

构造函数：
```
class Person{
 public:
     Person(){
         cout<< "no param constructor!" << endl;
         mAge= 0;
     }
     //有参构造函数
     Person(int age){
         cout<< "1 param constructor!" << endl;
         mAge= age;
     }
     //拷贝构造函数(复制构造函数) 使用另一个对象初始化本对象
     <!-- 拷贝构造函数传常引用的好处：
       避免不必要的拷贝：如果传递对象本身（而不是引用），在函数调用时会发生对象的拷贝，这可能会导致性能损失
       避免递归调用：如果使用值传递（传递对象本身），在调用拷贝构造函数时又会创建一个临时对象，导致无限递归调用拷贝构造函数，这将导致栈溢出。使用引用传递避免了递归调用的问题。

       如果传递的是指针呢？
       如果传递的是指针，拷贝构造函数可能需要在堆上创建额外的副本，这可能会增加内存开销和复杂性
       空指针检查：在使用指针时，需要进行空指针检查，以确保传递的指针是有效的，否则可能会导致未定义行为
       手动内存管理：如果在拷贝构造函数内部使用了动态内存分配（例如 new 操作），需要在适当的时候进行内存释放（delete 操作），以防止内存泄漏 -->
     Person(const Person& person){
         cout<< "copy constructor!" << endl;
         mAge= person.mAge;
     }
     //打印年龄
     void PrintPerson(){
         cout<< "Age:" << mAge << endl;
     }
     private:
         int mAge;
 };
 //1. 无参构造调用方式
 void test01(){
     //调用无参构造函数
     Person person1; 
     person1.PrintPerson();
     //无参构造函数错误调用方式
     //Person person2();
     //person2.PrintPerson();
 }
 //2. 调用有参构造函数
 void test02(){
     //第一种 括号法，最常用
     Personperson01(100);
     person01.PrintPerson();
     //调用拷贝构造函数
     Personperson02(person01);
     person02.PrintPerson();
     //第二种 匿名对象(显示调用构造函数)
     Person(200); //匿名对象，没有名字的对象
     Personperson03 = Person(300);
     person03.PrintPerson();
     //注意: 使用匿名对象初始化判断调用哪一个构造函数，要看匿名对象的参数类型
     Personperson06(Person(400)); //等价于 Person person06 = Person(400);
     person06.PrintPerson();
     //第三种 =号法 隐式转换
     Personperson04 = 100; //Person person04 =  Person(100)
     person04.PrintPerson();
     //调用拷贝构造
     Personperson05 = person04; //Person person05 =  Person(person04)
     person05.PrintPerson();
 }
```