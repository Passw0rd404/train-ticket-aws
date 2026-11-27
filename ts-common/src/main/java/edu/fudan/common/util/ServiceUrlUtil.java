package edu.fudan.common.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public final class ServiceUrlUtil {

    private static final Map<String, String> SERVICE_URLS;

    static {
        Map<String, String> urls = new HashMap<>();
        urls.put("ts-admin-basic-info-service", "http://ts-admin-basic-info-service.tt-no-secrets.svc.cluster.local:18767");
        urls.put("ts-admin-order-service", "http://ts-admin-order-service.tt-no-secrets.svc.cluster.local:16112");
        urls.put("ts-admin-route-service", "http://ts-admin-route-service.tt-no-secrets.svc.cluster.local:16113");
        urls.put("ts-admin-travel-service", "http://ts-admin-travel-service.tt-no-secrets.svc.cluster.local:16114");
        urls.put("ts-admin-user-service", "http://ts-admin-user-service.tt-no-secrets.svc.cluster.local:16115");
        urls.put("ts-assurance-service", "http://ts-assurance-service.tt-mysql.svc.cluster.local:18888");
        urls.put("ts-auth-service", "http://ts-auth-service.tt-mysql.svc.cluster.local:12340");
        urls.put("ts-avatar-service", "http://ts-avatar-service.tt-no-secrets.svc.cluster.local:17001");
        urls.put("ts-basic-service", "http://ts-basic-service.tt-no-secrets.svc.cluster.local:15680");
        urls.put("ts-cancel-service", "http://ts-cancel-service.tt-no-secrets.svc.cluster.local:18885");
        urls.put("ts-config-service", "http://ts-config-service.tt-mysql.svc.cluster.local:15679");
        urls.put("ts-consign-price-service", "http://ts-consign-price-service.tt-mysql.svc.cluster.local:16110");
        urls.put("ts-consign-service", "http://ts-consign-service.tt-mysql.svc.cluster.local:16111");
        urls.put("ts-contacts-service", "http://ts-contacts-service.tt-mysql.svc.cluster.local:12347");
        urls.put("ts-delivery-service", "http://ts-delivery-service.tt-mysql-rabbitmq.svc.cluster.local:18808");
        urls.put("ts-execute-service", "http://ts-execute-service.tt-no-secrets.svc.cluster.local:12386");
        urls.put("ts-food-delivery-service", "http://ts-food-delivery-service.tt-mysql.svc.cluster.local:18957");
        urls.put("ts-food-service", "http://ts-food-service.tt-mysql-rabbitmq.svc.cluster.local:18856");
        urls.put("ts-gateway-service", "http://ts-gateway-service.tt-no-secrets.svc.cluster.local:18888");
        urls.put("ts-inside-payment-service", "http://ts-inside-payment-service.tt-mysql.svc.cluster.local:18673");
        urls.put("ts-news-service", "http://ts-news-service.tt-no-secrets.svc.cluster.local:12862");
        urls.put("ts-notification-service", "http://ts-notification-service.tt-notification.svc.cluster.local:17853");
        urls.put("ts-order-other-service", "http://ts-order-other-service.tt-mysql.svc.cluster.local:12032");
        urls.put("ts-order-service", "http://ts-order-service.tt-mysql.svc.cluster.local:12031");
        urls.put("ts-payment-service", "http://ts-payment-service.tt-mysql.svc.cluster.local:19001");
        urls.put("ts-preserve-other-service", "http://ts-preserve-other-service.tt-no-secrets.svc.cluster.local:14569");
        urls.put("ts-preserve-service", "http://ts-preserve-service.tt-no-secrets.svc.cluster.local:14568");
        urls.put("ts-price-service", "http://ts-price-service.tt-mysql.svc.cluster.local:16579");
        urls.put("ts-rebook-service", "http://ts-rebook-service.tt-no-secrets.svc.cluster.local:18886");
        urls.put("ts-route-plan-service", "http://ts-route-plan-service.tt-no-secrets.svc.cluster.local:14578");
        urls.put("ts-route-service", "http://ts-route-service.tt-mysql.svc.cluster.local:11178");
        urls.put("ts-seat-service", "http://ts-seat-service.tt-no-secrets.svc.cluster.local:18898");
        urls.put("ts-security-service", "http://ts-security-service.tt-mysql.svc.cluster.local:11188");
        urls.put("ts-station-food-service", "http://ts-station-food-service.tt-mysql.svc.cluster.local:18855");
        urls.put("ts-station-service", "http://ts-station-service.tt-mysql.svc.cluster.local:12345");
        urls.put("ts-ticket-office-service", "http://ts-ticket-office-service.tt-mysql.svc.cluster.local:16108");
        urls.put("ts-train-food-service", "http://ts-train-food-service.tt-mysql.svc.cluster.local:19999");
        urls.put("ts-train-service", "http://ts-train-service.tt-mysql.svc.cluster.local:14567");
        urls.put("ts-travel2-service", "http://ts-travel2-service.tt-mysql.svc.cluster.local:16346");
        urls.put("ts-travel-plan-service", "http://ts-travel-plan-service.tt-no-secrets.svc.cluster.local:14322");
        urls.put("ts-travel-service", "http://ts-travel-service.tt-mysql.svc.cluster.local:12346");
        urls.put("ts-user-service", "http://ts-user-service.tt-mysql.svc.cluster.local:12342");
        urls.put("ts-verification-code-service", "http://ts-verification-code-service.tt-no-secrets.svc.cluster.local:15678");
        urls.put("ts-voucher-service", "http://ts-voucher-service.tt-mysql.svc.cluster.local:16101");
        urls.put("ts-wait-order-service", "http://ts-wait-order-service.tt-mysql.svc.cluster.local:17525");
        SERVICE_URLS = Collections.unmodifiableMap(urls);
    }

    private ServiceUrlUtil() {
    }

    public static String getServiceUrl(String serviceName) {
        String envKey = serviceName.toUpperCase(Locale.ROOT).replace('-', '_') + "_URL";
        String override = System.getenv(envKey);
        if (override != null && !override.isEmpty()) {
            return override;
        }
        return SERVICE_URLS.getOrDefault(serviceName, "http://" + serviceName);
    }
}
