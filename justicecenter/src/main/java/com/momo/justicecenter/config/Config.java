package com.momo.justicecenter.config;

import com.google.gson.annotations.SerializedName;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Config {
    @SerializedName("resources")
    private Map<String, List<ResourceConfig>> mResourcesConfigs;
    @SerializedName("sceneLists")
    private List<SceneConfig> mSceneConfigs;

    public Map<String, List<ResourceConfig>> getResourcesConfigs() {
        return mResourcesConfigs;
    }

    public void setResourcesConfigs(Map<String, List<ResourceConfig>> resourcesConfigs) {
        mResourcesConfigs = resourcesConfigs;
    }

    public List<SceneConfig> getSceneConfigs() {
        return mSceneConfigs;
    }

    public void setSceneConfigs(List<SceneConfig> sceneConfigs) {
        mSceneConfigs = sceneConfigs;
    }

    public Set<String> getSceneBusinesses(String sceneID) {
        if (mSceneConfigs != null) {
            for (SceneConfig sceneConfig : mSceneConfigs) {
                if (sceneID.equals(sceneConfig.getName())) {
                    List<String> scene = sceneConfig.getScene();
                    if (scene != null) {
                        return new HashSet<>(scene);
                    }
                }
            }
        }
        return new HashSet<>();
    }
}
