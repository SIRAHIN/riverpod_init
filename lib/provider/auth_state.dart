class AuthState {
  final bool isPasswordVisible;
  final String selectedGender;
  final double sliderValue;
  final bool isSuccess;
  final String? errorMessage; 

  AuthState({
    this.isPasswordVisible = false,
    this.selectedGender = '',
    this.sliderValue = 0.0,
    this.isSuccess = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isPasswordVisible,
    String? selectedGender,
    double? sliderValue,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AuthState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      selectedGender: selectedGender ?? this.selectedGender,
      sliderValue: sliderValue ?? this.sliderValue,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}