import Foundation

/// 生成在每个页面 document start 注入的 JS，覆盖表面参数：
/// navigator.language / languages、screen 尺寸、devicePixelRatio、时区（Intl + getTimezoneOffset）。
/// 注意：这只是 JS 层覆盖，引擎级指纹（canvas / WebGL / 字体）改不了，网站可检测出注入痕迹。
enum FingerprintScript {
    static func make(for profile: BrowserProfile) -> String {
        var lines: [String] = []
        lines.append("try {")

        let lang = jsString(profile.language)
        lines.append("Object.defineProperty(navigator, 'language', { get: function() { return \(lang); } });")
        lines.append("Object.defineProperty(navigator, 'languages', { get: function() { return [\(lang)]; } });")

        if let s = profile.screenSize {
            lines.append("Object.defineProperty(window.screen, 'width', { get: function() { return \(s.width); } });")
            lines.append("Object.defineProperty(window.screen, 'height', { get: function() { return \(s.height); } });")
            lines.append("Object.defineProperty(window.screen, 'availWidth', { get: function() { return \(s.width); } });")
            lines.append("Object.defineProperty(window.screen, 'availHeight', { get: function() { return \(s.height); } });")
            lines.append("Object.defineProperty(window, 'devicePixelRatio', { get: function() { return \(s.dpr); } });")
        }

        if !profile.timeZoneId.isEmpty {
            lines.append(timezoneJS(tzLiteral: jsString(profile.timeZoneId)))
        }

        lines.append("} catch (e) {}")
        return "(function() {\n" + lines.joined(separator: "\n") + "\n})();"
    }

    /// 把 Swift 字符串安全地编码成 JS 字符串字面量（走 JSON 编码再剥掉数组括号）。
    private static func jsString(_ s: String) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: [s]),
           let text = String(data: data, encoding: .utf8) {
            return String(text.dropFirst().dropLast())
        }
        return "'\(s)'"
    }

    private static func timezoneJS(tzLiteral: String) -> String {
        return """
        var __tz = \(tzLiteral);
        var __origResolved = Intl.DateTimeFormat.prototype.resolvedOptions;
        Intl.DateTimeFormat.prototype.resolvedOptions = function() {
            var o = __origResolved.call(this);
            o.timeZone = __tz;
            return o;
        };
        function __tzOffset(date) {
            var dtf = new Intl.DateTimeFormat('en-US', { timeZone: __tz, hour12: false, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' });
            var parts = {};
            dtf.formatToParts(date).forEach(function(p) { parts[p.type] = p.value; });
            var asUTC = Date.UTC(parseInt(parts.year, 10), parseInt(parts.month, 10) - 1, parseInt(parts.day, 10), parseInt(parts.hour, 10) % 24, parseInt(parts.minute, 10), parseInt(parts.second, 10));
            return Math.round((date.getTime() - asUTC) / 60000);
        }
        Date.prototype.getTimezoneOffset = function() { return __tzOffset(this); };
        """
    }
}
