using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MotionBlurCamera : MonoBehaviour
{
    Camera cm;

    public Shader sDepthBuffer;
    public Shader sColorBuffer;
    public Shader stest;
    Material mtest;
    Material mDepthBuffer;
    Material mColorBuffer;
    RenderTexture dbuffer;
    RenderTexture sdbuffer;
    RenderTexture cbuffer;
    RenderTexture scbuffer;
    public float frames;
    public float acc;
     void OnEnable() {
        
        cm=GetComponent<Camera>();
        cm.depthTextureMode |= DepthTextureMode.Depth;

        if(sDepthBuffer)mDepthBuffer=new Material(sDepthBuffer);
        if(sColorBuffer)mColorBuffer=new Material(sColorBuffer);
        if (stest) mtest = new Material(stest);
        Debug.Log(SystemInfo.supportedRenderTargetCount);

    }

    void OnRenderImage(RenderTexture src, RenderTexture dest) {

        //if (cbuffer == null)
        //{
        //    DestroyImmediate(cbuffer);
        //    cbuffer = new RenderTexture(src.width, src.height, 0);
        //    cbuffer.hideFlags = HideFlags.HideInHierarchy;
        //    Graphics.Blit(src, cbuffer);
        //    Debug.Log("first frame");
        //    return;
        //}

        //mtest.SetTexture("_OldFrame", cbuffer);
        //mtest.SetTexture("_CurFrame", src);

        //Graphics.SetRenderTarget(cbuffer);
        //Graphics.Blit(src, cbuffer, mtest);
        //Graphics.Blit(cbuffer, dest);
        
        //return;
        if (cbuffer==null){
            DestroyImmediate(cbuffer);
            cbuffer=new RenderTexture(src.width,src.height,0);
            cbuffer.hideFlags=HideFlags.HideAndDontSave;
            Graphics.Blit(src,cbuffer);

            DestroyImmediate(scbuffer);
            scbuffer = new RenderTexture(src.width, src.height, 0);
            scbuffer.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(src, scbuffer);
        }
        if(dbuffer==null){
            DestroyImmediate(dbuffer);
            dbuffer=new RenderTexture(src.width,src.height,0, RenderTextureFormat.ARGBFloat);
            dbuffer.hideFlags=HideFlags.HideAndDontSave;

            mDepthBuffer.SetTexture("_DepthBuffer",dbuffer);
            mDepthBuffer.SetFloat("_Num",frames);
            Graphics.Blit(src,dbuffer,mDepthBuffer);

            DestroyImmediate(sdbuffer);
            sdbuffer = new RenderTexture(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
            sdbuffer.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(dbuffer, sdbuffer);
        }

        if(mDepthBuffer!=null&&mColorBuffer!=null){

            

            Graphics.Blit(cbuffer, scbuffer);
            mColorBuffer.SetTexture("_DepthBuffer", dbuffer);
            mColorBuffer.SetTexture("_CurFrame", src);
           
            mColorBuffer.SetTexture("_OldFrame", scbuffer);
            mColorBuffer.SetFloat("_AccunOrig", acc);
            Graphics.Blit(src, cbuffer, mColorBuffer);

            Graphics.Blit(dbuffer, sdbuffer);
            mDepthBuffer.SetTexture("_DepthBuffer", sdbuffer);
            mDepthBuffer.SetFloat("_Num", frames);
            Graphics.Blit(src, dbuffer, mDepthBuffer);


            Graphics.Blit(cbuffer, dest);



        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
