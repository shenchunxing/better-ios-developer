### 数组
```
int a[4] = {2, 5};//当数组为整型时，初始化未确定初值的元素，默认为0，所以上面的a[2]、a[3]都为0


实参和形参
// b是test函数的形参(形式参数)
void test(int b[]) { // 也可以写int b[3]
    b[0] = 9;
}

int main() {
    int a[3];
    a[0] = 10;
    printf("函数调用前的a[0]：%d\n", a[0]);//10
    test(a); // a是test函数的实参(实际参数)
    printf("函数调用后的a[0]：%d", a[0]); //9
    return 0;
}
```

### 字符串
```
等价写法
    char string[6] = {'H', 'e', 'l', 'l', 'o', '\0'};
    char string2[6] = "Hello";
```
C 中对字符串操作的 API：
strcpy(s1, s2); 复制字符串 s2 到字符串 s1。
strcat(s1, s2); 连接字符串 s2 到字符串 s1 的末尾。
strlen(s1); 返回字符串 s1 的长度。
strcmp(s1, s2); 如果 s1 和 s2 是相同的，则返回 0；如果 s1<s2 则返回小于 0；如果 s1>s2 则返回大于 0。
strchr(s1, ch); 返回一个指针，指向字符串 s1 中字符 ch 的第一次出现的位置。
strstr(s1, s2); 返回一个指针，指向字符串 s1 中字符串 s2 的第一次出现的位置。

### 指针
```
 /*
     一个指针变量 占据内存的大小,跟指针的类型无关:
     一个指针在32位的计算机上，占4个字节;
     一个指针在64位的计算机上，占8个字节。
     */
    int *a;
    long*b;
    float*c;
    double*d;
    char*e;
    printf("一个int类型指针占据内存大小：%lu \n",sizeof(a));//8
    printf("一个long类型指针占据内存大小：%lu \n",sizeof(b));//8
    printf("一个float类型指针占据内存大小：%lu \n",sizeof(c));//8
    printf("一个double类型指针占据内存大小：%lu \n",sizeof(d));//8
    printf("一个char类型指针占据内存大小：%lu \n",sizeof(e));//8
```

### 结构体、位域
```
struct status2{
    int a:1;
    int b:1;
    int c:1;
};//占用3位，int类型有8位，因此占用1个字节。
struct bean {
  int a:8;
  int b:4;
  int c:4;
};//占用2字节

注意：一个位域存储在同一个字节中，如一个字节所剩空间不够存放另一位域时，则会从下一单元起存放该位域。
struct bean{
  unsigned a:4;
  unsigned  :4;//空域
  unsigned b:4;//从下一个单元开始存放
  unsigned c:4;
} //占用2字节
```

### 共用体
允许在相同的内存位置存储不同的数据类型，但是任何时候只能有一个成员带有值。
```
union Data {
    int i;
    float f;
    char str[20];
};共用体占用的内存应足够存储共用体中最大的成员。
```

### typedef
```
typedef struct Books {
    char title[50];
    char author[50];
    char subject[50];
    int book_id;
} Book;

//给Books一个别名Book
Book book;
     strcpy( book.title, "C 教程");
     strcpy( book.author, "Runoob");
     strcpy( book.subject, "编程语言");
     book.book_id = 12345;
```

### 输入输出
```
int getchar(void) //从屏幕读取下一个可用的字符，并把它返回为一个整数。这个函数在同一个时间内只会读取一个单一的字符。您可以在循环内使用这个方法，以便从屏幕上读取多个字符

int putchar(int c) //把字符输出到屏幕上，并返回相同的字符。这个函数在同一个时间内只会输出一个单一的字符。您可以在循环内使用这个方法，以便在屏幕上输出多个字符。

char *gets(char *s) //从 stdin 读取一行到 s 所指向的缓冲区，直到一个终止符或 EOF。

int puts(const char *s) //把字符串 s 和一个尾随的换行符写入到 stdout。

FILE *fopen( const char * filename, const char * mode );//创建一个新的文件或者打开一个已有的文件

int fclose( FILE *fp );//关闭文件

int fputc(int c,FILE *fp); //把参数 c 的字符值写入到 fp 所指向的输出流中

int fputs( const char *s, FILE *fp ); //把字符串 s 写入到 fp 所指向的输出流中

int fgetc( FILE * fp ); 从 fp 所指向的输入文件中读取一个字符
char *fgets( char *buf, int n, FILE *fp ); //从 fp 所指向的输入流中读取 n - 1 个字符。它会把读取的字符串复制到缓冲区 buf，并在最后追加一个 null 字符来终止字符串。

```

### 预处理器
```
#undef  FILE_SIZE
#define FILE_SIZE 42  <!-- 取消已定义的 FILE_SIZE，并定义它为 42。 -->

#ifdef DEBUG
   <!-- 如果定义了 DEBUG，则执行处理语句 -->
#endif

#ifndef MESSAGE
   <!-- 只有当 MESSAGE 未定义时，才定义 MESSAGE -->
#endif

```

### 预定义宏
```
void main() {
    //这会包含当前文件名，一个字符串常量。
    printf("File :%s\n", __FILE__);
    //当前日期，一个以 "MMM DD YYYY" 格式表示的字符常量。
    printf("Date :%s\n", __DATE__);
    //当前时间，一个以 "HH:MM:SS" 格式表示的字符常量。
    printf("Time :%s\n", __TIME__);
    //这会包含当前行号，一个十进制常量。
    printf("Line :%d\n", __LINE__);
    //当编译器以 ANSI 标准编译时，则定义为 1。
    printf("ANSI :%d\n", __STDC__);
} 

```

### 预处理器运算符
```
#define  message_for(a, b)  \
    printf(#a " and " #b ": We love you!\n")  //举例:Carole and Debra: We love you!

#define tokenpaster(n) printf ("token" #n " = %d", token##n) //举例：token34 = 40

<!-- 确保只引用一次 -->
#ifndef HEADER_FILE
#define HEADER_FILE

the entire header file file

#endif  

<!-- 条件引入方式1 -->
#if SYSTEM_1
   # include "system_1.h"
#elif SYSTEM_2
   # include "system_2.h"
#elif SYSTEM_3
   ...
#endif 

<!-- 条件引入方式2 -->
 #define SYSTEM_H "system_1.h"
 ...
 #include SYSTEM_H  


```

### 可变参数
```
<!-- num指的是可变参数的数量 -->
 double average(int num,...){
     va_list  vaList;
     double  sum = 0.0;
     int i ;
     //为 num 个参数初始化 valist
     va_start(vaList,num);
     //访问所有赋给 vaList 的参数
    for (int j = 0; j < num; j++) {
        sum += va_arg(vaList, int);
    }
    //清理为valist 保留的内存
    va_end(vaList);
    return sum/num;
 }

 void main(){
     printf("Average of 2, 3, 4, 5 = %f\n", average(4, 2,3,4,5));
     printf("Average of 5, 10, 15 = %f\n", average(3, 5,10,15));
 }

```

### 内存管理
```
<!-- 在内存中动态地分配 num 个长度为 size 的连续空间，并将每一个字节都初始化为 0。所以它的结果是分配了 num*size 个字节长度的内存空间，并且每个字节的值都是0。 -->
void *calloc(int num, int size);

<!-- 该函数释放 address 所指向的内存块,释放的是动态分配的内存空间。 -->
void free(void address);    

<!-- 在堆区分配一块指定大小的内存空间，用来存放数据。这块内存空间在函数执行完成后不会被初始化，它们的值是未知的 -->
void malloc(int num);

<!-- 该函数重新分配内存，把内存扩展到 newsize。 -->
void realloc(void address, int newsize)
```
