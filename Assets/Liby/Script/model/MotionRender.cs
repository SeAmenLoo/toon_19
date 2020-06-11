using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionRender : MonoBehaviour
{
    // Start is called before the first frame update
    SkinnedMeshRenderer[] skinnedMeshRenderers;
    public GameObject bakeMeshParent;
    void Start()
    {
        
        skinnedMeshRenderers=GetComponentsInChildren<SkinnedMeshRenderer>();
        for(int i=0;i<skinnedMeshRenderers.Length;i++){
            
            AnimSkin animSkin= skinnedMeshRenderers[i].gameObject.AddComponent<AnimSkin>();
            
            animSkin.modelSet=ModelSet.Skin;
            
            GameObject bakeMesh=new GameObject();
            bakeMesh.AddComponent<MeshFilter>();
            bakeMesh.AddComponent<MeshRenderer>();
            
            bakeMesh.name="bk_"+skinnedMeshRenderers[i].gameObject.name;
            bakeMesh.transform.parent= animSkin.transform;
            bakeMesh.transform.localPosition = Vector3.zero;
            bakeMesh.transform.localEulerAngles = Vector3.zero;

            animSkin.objSkin=bakeMesh;
            skinnedMeshRenderers[i].enabled = false;
            animSkin.StartMesh();
            //bakeMeshParent
            //animSkin=skinnedMeshRenderers[i].gameObject
        }
    }

    
}
