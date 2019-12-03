package com.momo.justicecenter.config;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SceneConfig {

    /**
     * name : live
     * scene : ["AntiSpam","AntiPorn"]
     */
    @SerializedName("name")
    private String name;
    @SerializedName("scene")
    private List<String> scene;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getScene() {
        return scene;
    }

    public void setScene(List<String> scene) {
        this.scene = scene;
    }
}
