package com.momo.justicecenter.resource;

public class ResResult {
    public boolean isOK;
    /**
     * 成功也可能ec不为0，因为可能是缓存
     */
    public int ec;
    public String em;

    private ResResult(boolean isOK, int ec, String em) {
        this.isOK = isOK;
        this.ec = ec;
        this.em = em;
    }

    public static ResResult create(boolean success, int ec, String em) {
        return new ResResult(success, ec, em);
    }

    @Override
    public String toString() {
        return "ResResult{" +
                "isOK=" + isOK +
                ", ec=" + ec +
                ", em='" + em + '\'' +
                '}';
    }
}
