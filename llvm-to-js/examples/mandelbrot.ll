@w = common global double 0.000000e+00
@h = common global double 0.000000e+00
@bail_out = common global double 0.000000e+00
@zoom_factor = common global double 0.000000e+00
@zoom = common global double 0.000000e+00

declare double @log10(double)
declare void @stroke(double)
declare void @point(double, double)
declare void @createCanvas(double, double)

define void @my_setup() {
  store double 6.400000e+02, double* @w
  store double 4.800000e+02, double* @h
  store double 2.000000e+00, double* @bail_out
  store double 1.400000e+00, double* @zoom_factor
  %1 = load double, double* @w
  %2 = fmul double %1, 0x3FD030A3D70A3D71
  store double %2, double* @zoom
  %3 = load double, double* @w
  %4 = load double, double* @h
  call void @createCanvas(double %3, double %4)
  ret void
}

define void @my_draw() {
  %1 = alloca i32
  %2 = alloca i32
  %3 = alloca i32
  %4 = alloca i32
  %5 = alloca double
  %6 = alloca double
  %7 = alloca double
  %8 = alloca double
  %9 = alloca double
  %10 = alloca double
  %11 = alloca double
  %12 = alloca double
  %13 = alloca double
  %14 = alloca i32
  %15 = load double, double* @w
  %16 = fdiv double %15, 2.000000e+00
  %17 = fmul double %16, 0x3FA9745D167DE830
  %18 = load double, double* @zoom
  %19 = call double @log10(double %18)
  %20 = fmul double %17, %19
  %21 = fptosi double %20 to i32
  store i32 %21, i32* %4
  store double -8.006710e-01, double* %9
  store double 1.583920e-01, double* %10
  store i32 0, i32* %2
  br label %22

; <label>:22:                                     ; preds = %116, %0
  %23 = load i32, i32* %2
  %24 = sitofp i32 %23 to double
  %25 = load double, double* @h
  %26 = fcmp olt double %24, %25
  br i1 %26, label %27, label %119

; <label>:27:                                     ; preds = %22
  store i32 0, i32* %1
  br label %28

; <label>:28:                                     ; preds = %112, %27
  %29 = load i32, i32* %1
  %30 = sitofp i32 %29 to double
  %31 = load double, double* @w
  %32 = fcmp olt double %30, %31
  br i1 %32, label %33, label %115

; <label>:33:                                     ; preds = %28
  store double 0.000000e+00, double* %11
  %34 = load double, double* %9
  %35 = load i32, i32* %1
  %36 = sitofp i32 %35 to double
  %37 = load double, double* @w
  %38 = fdiv double %37, 2.000000e+00
  %39 = fsub double %36, %38
  %40 = load double, double* @zoom
  %41 = fdiv double %39, %40
  %42 = fadd double %34, %41
  store double %42, double* %7
  store double %42, double* %5
  %43 = load double, double* %10
  %44 = load i32, i32* %2
  %45 = sitofp i32 %44 to double
  %46 = load double, double* @h
  %47 = fdiv double %46, 2.000000e+00
  %48 = fsub double %45, %47
  %49 = load double, double* @zoom
  %50 = fdiv double %48, %49
  %51 = fadd double %43, %50
  store double %51, double* %8
  store double %51, double* %6
  store i32 0, i32* %3
  br label %52

; <label>:52:                                     ; preds = %89, %33
  %53 = load i32, i32* %3
  %54 = load i32, i32* %4
  %55 = icmp sle i32 %53, %54
  br i1 %55, label %56, label %62

; <label>:56:                                     ; preds = %52
  %57 = load double, double* %11
  %58 = load double, double* @bail_out
  %59 = load double, double* @bail_out
  %60 = fmul double %58, %59
  %61 = fcmp olt double %57, %60
  br label %62

; <label>:62:                                     ; preds = %56, %52
  %63 = phi i1 [ false, %52 ], [ %61, %56 ]
  br i1 %63, label %64, label %92

; <label>:64:                                     ; preds = %62
  %65 = load double, double* %5
  %66 = load double, double* %5
  %67 = fmul double %65, %66
  %68 = load double, double* %6
  %69 = load double, double* %6
  %70 = fmul double %68, %69
  %71 = fsub double %67, %70
  %72 = load double, double* %7
  %73 = fadd double %71, %72
  store double %73, double* %12
  %74 = load double, double* %5
  %75 = fmul double 2.000000e+00, %74
  %76 = load double, double* %6
  %77 = fmul double %75, %76
  %78 = load double, double* %8
  %79 = fadd double %77, %78
  store double %79, double* %13
  %80 = load double, double* %12
  store double %80, double* %5
  %81 = load double, double* %13
  store double %81, double* %6
  %82 = load double, double* %12
  %83 = load double, double* %12
  %84 = fmul double %82, %83
  %85 = load double, double* %13
  %86 = load double, double* %13
  %87 = fmul double %85, %86
  %88 = fadd double %84, %87
  store double %88, double* %11
  br label %89

; <label>:89:                                     ; preds = %64
  %90 = load i32, i32* %3
  %91 = add nsw i32 %90, 1
  store i32 %91, i32* %3
  br label %52

; <label>:92:                                     ; preds = %62
  %93 = load i32, i32* %3
  %94 = load i32, i32* %4
  %95 = icmp slt i32 %93, %94
  br i1 %95, label %96, label %104

; <label>:96:                                     ; preds = %92
  %97 = load i32, i32* %3
  %98 = sitofp i32 %97 to double
  %99 = load i32, i32* %4
  %100 = sitofp i32 %99 to double
  %101 = fdiv double %98, %100
  %102 = fmul double %101, 2.550000e+02
  %103 = fptosi double %102 to i32
  store i32 %103, i32* %14
  br label %105

; <label>:104:                                    ; preds = %92
  store i32 0, i32* %14
  br label %105

; <label>:105:                                    ; preds = %104, %96
  %106 = load i32, i32* %14
  %107 = sitofp i32 %106 to double
  call void @stroke(double %107)
  %108 = load i32, i32* %1
  %109 = sitofp i32 %108 to double
  %110 = load i32, i32* %2
  %111 = sitofp i32 %110 to double
  call void @point(double %109, double %111)
  br label %112

; <label>:112:                                    ; preds = %105
  %113 = load i32, i32* %1
  %114 = add nsw i32 %113, 1
  store i32 %114, i32* %1
  br label %28

; <label>:115:                                    ; preds = %28
  br label %116

; <label>:116:                                    ; preds = %115
  %117 = load i32, i32* %2
  %118 = add nsw i32 %117, 1
  store i32 %118, i32* %2
  br label %22

; <label>:119:                                    ; preds = %22
  %120 = load double, double* @zoom_factor
  %121 = load double, double* @zoom
  %122 = fmul double %121, %120
  store double %122, double* @zoom
  ret void
}