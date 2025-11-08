// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'CodeBase';

  @override
  String get common_ok => 'Đồng ý';

  @override
  String get common_cancel => 'Hủy';

  @override
  String get common_save => 'Lưu';

  @override
  String get common_delete => 'Xóa';

  @override
  String get common_edit => 'Chỉnh sửa';

  @override
  String get common_search => 'Tìm kiếm';

  @override
  String get common_loading => 'Đang tải...';

  @override
  String get common_error => 'Lỗi';

  @override
  String get common_success => 'Thành công';

  @override
  String get common_warning => 'Cảnh báo';

  @override
  String get common_info => 'Thông tin';

  @override
  String get common_yes => 'Có';

  @override
  String get common_no => 'Không';

  @override
  String get common_submit => 'Gửi';

  @override
  String get common_back => 'Quay lại';

  @override
  String get common_next => 'Tiếp theo';

  @override
  String get common_skip => 'Bỏ qua';

  @override
  String get common_done => 'Hoàn thành';

  @override
  String get common_retry => 'Thử lại';

  @override
  String get common_close => 'Đóng';

  @override
  String get auth_login => 'Đăng nhập';

  @override
  String get auth_register => 'Đăng ký';

  @override
  String get auth_logout => 'Đăng xuất';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Mật khẩu';

  @override
  String get auth_confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get auth_forgotPassword => 'Quên mật khẩu?';

  @override
  String get auth_dontHaveAccount => 'Chưa có tài khoản?';

  @override
  String get auth_alreadyHaveAccount => 'Đã có tài khoản?';

  @override
  String get auth_loginSuccess => 'Đăng nhập thành công';

  @override
  String get auth_loginFailed => 'Đăng nhập thất bại';

  @override
  String get auth_registerSuccess => 'Đăng ký thành công';

  @override
  String get auth_registerFailed => 'Đăng ký thất bại';

  @override
  String get dashboard_title => 'Bảng điều khiển';

  @override
  String get dashboard_welcome => 'Chào mừng trở lại!';

  @override
  String get dashboard_stats => 'Thống kê';

  @override
  String get profile_title => 'Hồ sơ';

  @override
  String get profile_editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_changePassword => 'Đổi mật khẩu';

  @override
  String get profile_name => 'Tên';

  @override
  String get profile_phone => 'Điện thoại';

  @override
  String get profile_address => 'Địa chỉ';

  @override
  String get profile_updateSuccess => 'Cập nhật hồ sơ thành công';

  @override
  String get profile_updateFailed => 'Cập nhật hồ sơ thất bại';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_theme => 'Giao diện';

  @override
  String get settings_language => 'Ngôn ngữ';

  @override
  String get settings_notifications => 'Thông báo';

  @override
  String get settings_about => 'Giới thiệu';

  @override
  String get settings_privacy => 'Chính sách bảo mật';

  @override
  String get settings_terms => 'Điều khoản dịch vụ';

  @override
  String get settings_light => 'Sáng';

  @override
  String get settings_dark => 'Tối';

  @override
  String get settings_system => 'Hệ thống';

  @override
  String get error_network => 'Không có kết nối internet';

  @override
  String get error_timeout => 'Hết thời gian chờ';

  @override
  String get error_server => 'Lỗi máy chủ';

  @override
  String get error_unknown => 'Đã xảy ra lỗi không xác định';

  @override
  String get error_unauthorized => 'Truy cập không được phép';

  @override
  String get field_default => 'Trường này';

  @override
  String validation_required(String field) {
    return '$field là bắt buộc';
  }

  @override
  String get validation_emailInvalid => 'Vui lòng nhập địa chỉ email hợp lệ';

  @override
  String validation_passwordTooShort(int min) {
    return 'Mật khẩu phải có ít nhất $min ký tự';
  }

  @override
  String get validation_passwordMismatch => 'Mật khẩu không khớp';

  @override
  String validation_minLength(String field, int min) {
    return '$field phải có ít nhất $min ký tự';
  }

  @override
  String validation_maxLength(String field, int max) {
    return '$field không được vượt quá $max ký tự';
  }

  @override
  String get validation_phoneInvalid => 'Vui lòng nhập số điện thoại hợp lệ';

  @override
  String get validation_urlInvalid => 'Vui lòng nhập URL hợp lệ';

  @override
  String get toast_success => 'Thành công!';

  @override
  String get toast_error => 'Lỗi!';

  @override
  String get toast_warning => 'Cảnh báo!';

  @override
  String get toast_info => 'Thông tin';

  @override
  String get empty_noData => 'Không có dữ liệu';

  @override
  String get empty_noResults => 'Không tìm thấy kết quả';

  @override
  String get empty_noNotifications => 'Không có thông báo';

  @override
  String get empty_tryAgain => 'Thử lại';

  @override
  String get error_retry => 'Thử lại';

  @override
  String get error_goBack => 'Quay lại';

  @override
  String get auth_welcomeBack => 'Chào mừng trở lại';

  @override
  String get auth_loginToContinue => 'Đăng nhập để tiếp tục';

  @override
  String get auth_createAccount => 'Tạo tài khoản';

  @override
  String get auth_signUpToContinue => 'Đăng ký để bắt đầu';

  @override
  String get auth_fullName => 'Họ và tên';

  @override
  String get dashboard_overview => 'Tổng quan';

  @override
  String get dashboard_recentActivity => 'Hoạt động gần đây';

  @override
  String get dashboard_viewAll => 'Xem tất cả';

  @override
  String get profile_personalInfo => 'Thông tin cá nhân';

  @override
  String get profile_accountSettings => 'Cài đặt tài khoản';

  @override
  String get profile_logout => 'Đăng xuất';

  @override
  String get profile_logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get settings_appearance => 'Giao diện';

  @override
  String get settings_general => 'Chung';

  @override
  String get settings_account => 'Tài khoản';

  @override
  String get settings_version => 'Phiên bản';

  @override
  String get action_apply => 'Áp dụng';

  @override
  String get action_confirm => 'Xác nhận';

  @override
  String get action_discard => 'Hủy bỏ';

  @override
  String get action_refresh => 'Làm mới';

  @override
  String get action_filter => 'Lọc';

  @override
  String get action_sort => 'Sắp xếp';

  @override
  String get action_share => 'Chia sẻ';

  @override
  String get action_export => 'Xuất';

  @override
  String get action_import => 'Nhập';

  @override
  String get hint_search => 'Tìm kiếm';

  @override
  String get hint_email => 'Nhập địa chỉ email';

  @override
  String get hint_password => 'Nhập mật khẩu';

  @override
  String get hint_confirmPassword => 'Nhập lại mật khẩu';

  @override
  String get hint_fullName => 'Nhập họ và tên';

  @override
  String get hint_phone => 'Nhập số điện thoại';

  @override
  String get hint_address => 'Nhập địa chỉ';

  @override
  String get hint_theme => 'Chọn giao diện';

  @override
  String get hint_language => 'Chọn ngôn ngữ';
}
