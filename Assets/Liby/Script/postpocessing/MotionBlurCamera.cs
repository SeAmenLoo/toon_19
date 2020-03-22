using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MotionBlurCamera : MonoBehaviour
{
    public enum CameraSet{
        test,
        normel,
        deleteFrame,
    }
    public CameraSet cameraSet;
    Camera cm;

    public Shader sDepthBuffer;
    public Shader sColorBuffer;
    public Shader stest;
    public Shader sDepth;
    Material mtest;
    Material mDepthBuffer;
    Material mColorBuffer;
    Material mDepth;

    CustomRenderTexture crt;
    RenderTexture dbuffer;
    RenderTexture sdbuffer;
    RenderTexture cbuffer;
    RenderTexture scbuffer;
    public float frames;
    public float acc;
    float timer = 0;
     void OnEnable() {
        
        cm=GetComponent<Camera>();
        cm.depthTextureMode |= DepthTextureMode.Depth;

        if(sDepthBuffer)mDepthBuffer=new Material(sDepthBuffer);
        if(sColorBuffer)mColorBuffer=new Material(sColorBuffer);
        if (stest) mtest = new Material(stest);
        if (sDepth) mDepth = new Material(sDepth);

    }
    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (cameraSet==CameraSet.test) {
            if (cbuffer == null)
            {
                DestroyImmediate(cbuffer);
                cbuffer = new RenderTexture(src.width, src.height, 0);
                cbuffer.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, cbuffer);
                Debug.Log("first frame");
                DestroyImmediate(scbuffer);
                scbuffer = new RenderTexture(src.width, src.height, 0);
                scbuffer.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, scbuffer);
                Graphics.Blit(cbuffer, dest);
                return;
            }

            // Graphics.Blit(cbuffer, scbuffer);
            mtest.SetFloat("_BlurAmount", acc);
            Graphics.Blit(scbuffer, cbuffer);
            mtest.SetTexture("_OldFrame", cbuffer);
            mtest.SetTexture("_CurFrame", src);


            
            Graphics.Blit(src, scbuffer, mtest);
            Graphics.Blit(scbuffer, dest);

            return;
        }
        
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
            Graphics.Blit(src, dbuffer, mDepth);
            //mDepthBuffer.SetTexture("_DepthBuffer",dbuffer);
            //mDepthBuffer.SetFloat("_Num",frames);
            //Graphics.Blit(src,dbuffer,mDepthBuffer);

            DestroyImmediate(sdbuffer);
            sdbuffer = new RenderTexture(src.width, src.height, 0, RenderTextureFormat.ARGBFloat);
            sdbuffer.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(dbuffer, sdbuffer);
        }

        if(mDepthBuffer!=null&&mColorBuffer!=null){


            Graphics.Blit(dbuffer, sdbuffer);
            mDepthBuffer.SetTexture("_DepthBuffer", sdbuffer);
            mDepthBuffer.SetFloat("_Num", frames);
            Graphics.Blit(src, dbuffer, mDepthBuffer);

            Graphics.Blit(cbuffer, scbuffer);
            mColorBuffer.SetTexture("_DepthBuffer", dbuffer);
            mColorBuffer.SetTexture("_CurFrame", src);
           
            mColorBuffer.SetTexture("_OldFrame", scbuffer);
            mColorBuffer.SetFloat("_AccumOrig", acc);
            Graphics.Blit(src, cbuffer, mColorBuffer);


            if (cameraSet == CameraSet.deleteFrame)
            {
                if (timer < 1)
                {
                    timer += (1 / frames);
                }
                else
                {
                    Graphics.Blit(cbuffer, dest);
                    timer = 0;
                }
            }
            else if(cameraSet == CameraSet.normel)
            {
                Graphics.Blit(cbuffer, dest);
            }

            



        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
