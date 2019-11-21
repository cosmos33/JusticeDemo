package com.momo.justicecenter.network.bean;

public class OuterResponseBean {

    /**
     * data : {"mzip":"a+6hNP7yquAlRQoD7zrAIA=="}
     * ec : 0
     * em : success
     * errcode : 0
     * errmsg : success
     * timesec : 1574322469
     */

    private DataBean data;
    private int ec;
    private String em;
    private int errcode;
    private String errmsg;
    private int timesec;

    public DataBean getData() {
        return data;
    }

    public void setData(DataBean data) {
        this.data = data;
    }

    public int getEc() {
        return ec;
    }

    public void setEc(int ec) {
        this.ec = ec;
    }

    public String getEm() {
        return em;
    }

    public void setEm(String em) {
        this.em = em;
    }

    public int getErrcode() {
        return errcode;
    }

    public void setErrcode(int errcode) {
        this.errcode = errcode;
    }

    public String getErrmsg() {
        return errmsg;
    }

    public void setErrmsg(String errmsg) {
        this.errmsg = errmsg;
    }

    public int getTimesec() {
        return timesec;
    }

    public void setTimesec(int timesec) {
        this.timesec = timesec;
    }

    public static class DataBean {
        /**
         * mzip : a+6hNP7yquAlRQoD7zrAIA==
         */

        private String mzip;

        public String getMzip() {
            return mzip;
        }

        public void setMzip(String mzip) {
            this.mzip = mzip;
        }
    }
}
