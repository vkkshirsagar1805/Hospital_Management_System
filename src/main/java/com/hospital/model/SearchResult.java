
package com.hospital.model;

public class SearchResult {

    private String type;
    private String id;
    private String title;
    private String description;
    private String status;
    private String url;

    public SearchResult(String type, String id, String title,
                        String description, String status, String url) {
        this.type = type;
        this.id = id;
        this.title = title;
        this.description = description;
        this.status = status;
        this.url = url;
    }

    public String getType() {
        return type;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getStatus() {
        return status;
    }

    public String getUrl() {
        return url;
    }
}
