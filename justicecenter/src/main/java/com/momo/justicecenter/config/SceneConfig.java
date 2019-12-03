package com.momo.justicecenter.config;

import java.util.List;

public class SceneConfig {

    /**
     * name : live
     * scene : ["AntiSpam","AntiPorn"]
     */

    private String name;
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
