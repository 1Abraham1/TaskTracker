Name:       ru.template.TaskTracker
Summary:    Моё приложение для ОС Аврора
Version:    0.1
Release:    1
License:    BSD-3-Clause
URL:        https://auroraos.ru
Source0:    %{name}-%{version}.tar.bz2

Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(auroraapp)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)

%description
Добрый день! Представляем вам Task Tracker — новое приложение для удобного и эффективного планирования задач, целей и повседневных дел. Оно разработано для людей среднего возраста, которым важно не только организовать свои задачи, но и управлять временем на длительный период. Мы стремимся сделать планирование простым, понятным и доступным.

%prep
%autosetup

%build
%qmake5
%make_build

%install
%make_install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
